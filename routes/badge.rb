get '/badge' do
  must_be_logged_in

  @user = User.find(session[:user_id])
  haml :badge
end

get '/badge/:eid.svg' do
  generate_svg "button" do
    user = User.find_by_external_id(params[:eid])
    user.compute_rating if user.rating.nil?
    @rating = user.rating.score || 0
    @clr = @rating > 0 ? "green" : (@rating == 0 ? "orange" : "black")
  end
end
