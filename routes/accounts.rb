get '/accounts' do
  must_be_logged_in

  @accounts = User.find(session[:user_id]).accounts

  haml :accounts
end

get '/account/delete/:account_id' do
  must_be_logged_in

  account = get_account
  account.transactions.delete_all
  account.delete

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
                   :name           => params[:user],
                   :owner          => params[:user],
                   :account_number => iban.to_local[:account_number],
                   :currency       => 'EUR',
                   :bank           => Bank.for_iban(iban))

  account.figo_credentials = params[:creds]

  redirect '/accounts'
end
