get '/add_account' do
  redirect '/' if session[:user_id].nil?

  haml :add_account
end

post '/add_account' do
  redirect '/' if session[:user_id].nil?

  @user = User.find(session[:user_id])
  if params[:creds_type] == "account"
    iban = "DE67900900424711951500"
    if account = @user.accounts.where(:iban => iban).first
      account.figo_credentials = params[:creds]
    else
      account = Account.create(:user => @user, :iban => iban)
      account.figo_credentials = params[:creds]
    end

    $figo_connection.add_account("DE", params[:creds], "90090042",iban, true)
  else
    ### Else this is a token
  end
  haml :add_account
end
