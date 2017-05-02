get '/login' do
  @message = session.delete(:message)
  @email = session.delete(:email)
  haml :login
end

get '/register' do
  haml :register
end

post '/login' do
  key = OpenSSL::PKey::RSA.new(ENV['RSA_PRIVATE_KEY'].gsub(/\\n/,"\n"))
  data = JSON(JWE.decrypt(params[:creds], key))

  case data["type"]
  when "register"
    if u = User.where(:email => data["email"].downcase).first
      @message = "Email already registered"
      @email = data["email"]
      @name = data["name"]
    else
      if data["password1"] != data["password2"]
        @message = "Passwords did not match"
        @email = data["email"]
        @name = data["name"]
      else
        u = User.create(:email => data["email"].downcase,
                        :name => data["name"])
        u.password = data["password1"]
        Mailer::Client.new.
          send_confirm_email({"confirm_link" =>
                               u.generate_email_confirmation_link,
                             "email"     => u.email,
                             "firstname" => u.name,
                             "lastname"  => ""})

        @message = "Thank You! Confirmation email has been sent."
      end
    end

  when "login"
    if user = User.where(:email => data["email"].downcase).first
      if user.has_confirmed?
        if user.password_match?(data["password"])
          session[:user_id] = user.id
          redirect "/"
        else
          @email = data["email"]
          @message = "Unknown Email or Wrong Password - take your pick"
        end
      else
        @email = data["email"]
        @message = "Email not yet confirmed, check your inbox"
      end
    else
      @email = data["email"]
      @message = "Unknown Email or Wrong Password - take your pick"
    end

  else
    @message = "Unknown Interaction With Server"
  end

  haml :login
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
