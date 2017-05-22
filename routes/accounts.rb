get '/accounts' do
  must_be_logged_in

  @message = session.delete(:message)
  @accounts = User.find(session[:user_id]).accounts

  haml :accounts
end

get '/account/delete/:account_id' do
  must_be_logged_in

  get_account.tap do |acc|
    acc.transactions.delete_all
    acc.delete
  end

  redirect '/accounts'
end

get '/add_account' do
  must_be_logged_in

  @message = session.delete(:message)
  haml :add_account
end

post '/add_account' do
  must_be_logged_in

  user = User.find(session[:user_id])
  iban = if IBANTools::IBAN.valid?(params[:iban])
           IBANTools::IBAN.new(params[:iban])
         else
           session[:message] = "IBAN: #{params[:iban]} is not valid"
           redirect "/add_account"
         end

  if iban.country_code != "DE"
    session[:message] = "IBAN: #{params[:iban]} is not a german account"
    redirect "/add_account"
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


  credentials = { "type" => "encrypted", "value" => params[:creds] }
  task = FigoHelper.start_session.
    add_account("de", credentials, iban.to_local[:blz], iban.code, true)

  session[:message] = task.task_token
  redirect '/accounts'
end

post '/iban/check' do
  must_be_logged_in

  return_json do
    { :r => IBANTools::IBAN.valid?(params[:iban]) }
  end
end

post '/iban/bankdetails' do
  must_be_logged_in

  return_json do
    iban = IBANTools::IBAN.new(params[:iban])

    { :form => haml(:"_figo_bank_form", :layout => false,
                    :locals => {
                      :bank => FigoSupportedBank.get_bank(iban),
                      :iban => iban
                    })
    }
  end
end
