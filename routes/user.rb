get '/profile' do
  must_be_logged_in

  haml :profile
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
      session[:email] = user.email
      session[:message] = "Email Confirmed!"
      redirect "/login"
    else
      redirect(to_email_confirm("TokenMismatch"))
    end
  end
end
