get '/rating' do
  redirect '/' if session[:figo_token].nil?

  figo_session     = Figo::Session.new(session[:figo_token])
  @accounts        = figo_session.accounts
  @current_account = figo_session.get_account(params[:account_id])
  @transactions    = @current_account.transactions
  @user            = figo_session.user

  haml :rating
end
