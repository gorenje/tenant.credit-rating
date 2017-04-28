get '/accounts' do
  redirect '/' if session[:user_id].nil?

  @accounts = User.find(session[:user_id]).accounts

  haml :accounts
end

get '/transactions/:account_id' do
  redirect '/' if session[:user_id].nil?

  @account = Account.where(:user_id => session[:user_id],
                           :id => params[:account_id]).first
  @transactions = @account.transactions

  haml :transactions
end
