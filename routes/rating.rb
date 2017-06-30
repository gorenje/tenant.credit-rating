get '/rating/:eid' do
  @user = User.find_by_external_id(params[:eid])
  @user.update_rating if @user && @user.rating.nil?
  haml :rating_user
end
