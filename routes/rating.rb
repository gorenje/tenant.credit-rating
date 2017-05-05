get '/rating/:eid' do
  @user = User.find_by_external_id(params[:eid])
  @user.compute_rating if @user.rating.nil?
  haml :rating_user
end

get '/rating' do
  redirect '/' if session[:user_id].nil?
  @user = User.find(session[:user_id])
  haml :rating
end
