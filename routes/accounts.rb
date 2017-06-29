post '/add_account' do
  return_json do
    user = User.find(session[:user_id])
    iban = IBANTools::IBAN.new(params[:iban])

    account = Account.
      create(:user     => user,
             :name     => user.name,
             :owner    => user.name,
             :currency => 'EUR',
             :bank     => Bank.for_figo_bank(FigoSupportedBank.get_bank(iban)))

    account.figo_credentials = params[:creds]

    begin
      user.create_or_update_figo_account
      task = account.add_account_to_figo
      { :status     => :ok,
        :msg        => ("Your account at #{account.bank.name} will be " +
                        "updated presently"),
        :account_id => account.id,
        :token      => task.task_token,
        :url        => "/accounts/#{account.id}/status/#{task.task_token}"
      }

    rescue Figo::Error => e
      { :status => :error,
        :msg    => e.message
      }
    end
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

get '/bank/lookup' do
  return_json do
    args = [params[:q].upcase + "%"]*3
    FigoSupportedBank.
      where("bic like ? or bank_code like ? or bank_name like ?", *args)
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
