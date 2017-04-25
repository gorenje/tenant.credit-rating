get '/rating' do
  redirect '/' if session[:user_id].nil?

  @user = User.find(session[:user_id])

  haml :rating
end
