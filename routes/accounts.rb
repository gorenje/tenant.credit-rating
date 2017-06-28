post '/add_account' do
  return_json do
    user = User.find(session[:user_id])
    iban = if IBANTools::IBAN.valid?(params[:iban])
             IBANTools::IBAN.new(params[:iban])
           else
             { :status => :error,
               :error => "IBAN: #{params[:iban]} is not valid"
             }
           end

    if iban.country_code != "DE"
      { :status => :error,
        :msg => "IBAN: #{params[:iban]} is not a german account"
      }
    end

    account = user.accounts.where(:iban => iban.code).first ||
      Account.create(:user           => user,
                     :iban           => iban.code,
                     :name           => user.name,
                     :owner          => user.name,
                     :account_number => iban.to_local[:account_number],
                     :currency       => 'EUR',
                     :bank           => Bank.for_iban(iban))

    account.figo_credentials = params[:creds]

    begin
      task = account.add_account_to_figo
    rescue Figo::Error => e
      { :status => :error,
        :msg => "Error Adding #{iban.code}: #{e.message}"
      }
    end

    { :status     => :ok,
      :msg        => ("Your account at #{account.bank.name} will be " +
                      "updated presently"),
      :account_id => account.id,
      :token      => task.task_token,
      :url        => "/accounts/#{account.id}/status/#{task.task_token}"
    }
  end
end

get '/accounts/:accountid/status/:token' do
  return_json do
    acc = Account.find(params[:accountid])
    user = User.find(session[:user_id])
    return {} if acc.user != user

    if params[:token] == acc.figo_task_token
      task = acc.figo_task
      if task.is_ended && !task.is_erroneous
        acc.refresh
        user.update_rating
        { :status => :ready,
          :rating => user.rating.score
        }
      else
        { :status => :working }
      end
    else
      { :status => :error,
        :msg => "mismatch"
      }
    end
  end
end

post '/iban/check' do
  return_json do
    { :r => (IBANTools::IBAN.valid?(params[:iban]) ||
             params[:iban].length == 8 || # blz
             params[:iban].length == 11 ) # bic
    }
  end
end

post '/iban/bankdetails' do
  return_json do
    iban = IBANTools::IBAN.new(params[:iban])

    { :form => haml(:"_figo_bank_form", :layout => false,
                    :locals => {
                      :bank => FigoSupportedBank.get_bank(iban)
                    })
    }
  end
end
