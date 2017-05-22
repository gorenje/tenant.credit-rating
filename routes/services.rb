get '/add_service' do
  must_be_logged_in

  @message = session.delete(:message)

  haml :add_service
end

post '/add_service' do
  must_be_logged_in

  service = FigoSupportedService.where(:bank_code => params[:servicecode]).first
  if service.nil?
    session[:message] = "Unknown Service: #{params[:servicecode]}"
    redirect "/add_service"
  end

  user = User.find(session[:user_id])

  account = user.accounts.where(:iban => service.bank_code).first ||
    Account.create(:user           => user,
                   :iban           => service.bank_code,
                   :name           => user.name,
                   :owner          => user.name,
                   :currency       => 'EUR',
                   :bank           => Bank.for_service(service))

  account.figo_credentials = params[:creds]


  credentials = { "type" => "encrypted", "value" => params[:creds] }
  task = FigoHelper.start_session.
    add_account("de", credentials, service.bank_code, nil, true)

  session[:message] = task.task_token
  redirect '/accounts'
end

post '/service/details' do
  must_be_logged_in

  return_json do
    bank = FigoSupportedService.where(:bank_code => params[:servicecode]).first

    { :form => haml(:"_figo_bank_form", :layout => false,
                    :locals => { :bank => bank, :iban => nil })
    }
  end
end
