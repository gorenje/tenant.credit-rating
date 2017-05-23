get '/badge' do
  @user = User.find(session[:user_id])
  haml :badge
end

get '/badge/:eid.svg' do
  generate_svg "button" do
    if user = User.find_by_external_id(params[:eid])
      user.compute_rating if user.rating.nil?
      @rating = user.rating.score || 0
      @clr = @rating > 0 ? "green" : (@rating == 0 ? "orange" : "black")
    else
      @rating = "---"
      @clr = "black"
    end
  end
end
