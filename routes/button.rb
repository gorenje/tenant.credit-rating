get '/button/:eid.svg' do
  generate_svg "button" do
    user = User.find_by_external_id(params[:eid])
    @bonitaet = user.rating
  end
end
