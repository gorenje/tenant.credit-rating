get '/figo/login' do
  redirect $figo_connection.
    login_url("qweqwe", "accounts=ro transactions=ro balance=ro user=ro")
end

get '/callback*' do
  if params['state'] != "qweqwe"
    raise Exception.new("Bogus redirect, wrong state")
  end

  token_hash = $figo_connection.obtain_access_token(params['code'])

  session[:figo_token] = token_hash['access_token']

  user = User.find_or_create_user_by_figo(session[:figo_token])
  user.login_token = params['code']
  session[:user_id] = user.id

  redirect "/accounts"
end

get '/logout' do
  session.delete(:user_id)
  session.delete(:figo_token)
  redirect '/'
end
