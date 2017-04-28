get '/login' do
  haml :login
end

post '/login' do
  puts params

  key = OpenSSL::PKey::RSA.new(ENV['RSA_PRIVATE_KEY'])
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
        @message = "Thank You! Confirmation email has been sent."
      end
    end
  when "login"
    puts User.where(:email => data["email"].downcase).first
    puts data["email"]

    if (user = User.where(:email => data["email"].downcase).first) &&
        user.password_match?(data["password"])
      session[:user_id] = user.id
      redirect "/"
    else
      @email = data["email"]
      @message = "Unknown Email or Wrong Password - take your pick"
    end
  else
    @message = "Unknown Interaction With Server"
  end

  haml :login
end
