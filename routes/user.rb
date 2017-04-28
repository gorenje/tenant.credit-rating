get '/add_account' do
  redirect '/' if session[:user_id].nil?

  haml :add_account
end

post '/add_account' do
  redirect '/' if session[:user_id].nil?

  @user = User.find(session[:user_id])
  if params[:creds_type] == "account"
    $figo_connection.add_account("DE", params[:creds], "90090042",
                                 "DE67900900424711951500", true)
  else
    ### Else this is a token
  end
  haml :add_account
end
