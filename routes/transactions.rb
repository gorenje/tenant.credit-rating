get '/transactions/:account_id' do
  redirect '/' if session[:user_id].nil?

  @account = Account.where(:user_id => session[:user_id],
                           :id => params[:account_id]).first
  @transactions = @account.transactions

  haml :transactions
end

get '/add_transactions/:account_id' do
  redirect '/' if session[:user_id].nil?

  @account = Account.where(:user_id => session[:user_id],
                           :id => params[:account_id]).first

  haml :transactions_upload
end

post '/add_transactions/:account_id' do
  redirect '/' if session[:user_id].nil?

  key = OpenSSL::PKey::RSA.new(ENV['RSA_PRIVATE_KEY'].gsub(/\\n/,"\n"))
  data = JSON(JWE.decrypt(params[:creds], key))

  file_data = Base64::decode64(data["filedata"].sub(/^.+base64,/,''))

  CSV.new(file_data.force_encoding('ISO-8859-1'),
          :headers => :first_line, :col_sep => ";", :quote_char => '"').
    each { |a| puts a }
end
