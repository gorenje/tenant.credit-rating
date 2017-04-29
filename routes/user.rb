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

get '/users/email-confirmation' do
  params[:r]
end

get '/user/emailconfirm' do
  if params_blank?(:email,:token)
    redirect to_email_confirm("MissingData")
  else
    email, salt = extract_email_and_salt(params[:email])
    if email.blank? or salt.blank?
      redirect(to_email_confirm("DataCorrupt"))
    end

    user = User.find_by_email(email)
    redirect(to_email_confirm("EmailUnknown")) if user.nil?

    if user.email_confirm_token_matched?(params[:token], salt)
      user.update(:has_confirmed => true, :confirm_token => nil)
      redirect(to_email_confirm("EmailSent"))
    else
      redirect(to_email_confirm("TokenMismatch"))
    end
  end
end
