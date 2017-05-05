get '/transactions/:account_id' do
  redirect '/' if session[:user_id].nil?

  @account      = get_account
  @transactions = @account.transactions

  haml :transactions
end

get '/add_transactions/:account_id' do
  redirect '/' if session[:user_id].nil?

  @account = get_account

  haml :transactions_upload
end

post '/add_transactions/:account_id' do
  redirect '/' if session[:user_id].nil?

  key       = OpenSSL::PKey::RSA.new(ENV['RSA_PRIVATE_KEY'].gsub(/\\n/, "\n"))
  data      = JSON(JWE.decrypt(params[:creds],                         key))
  file_data = Base64::decode64(data["filedata"].sub(/^.+base64,/, ''))
  account   = get_account

  impClass = TransactionImporter.handler_for(data["format"])
  importer = impClass.new(account)
  importer.import(file_data)

  redirect "/transactions/#{account.id}"
end
