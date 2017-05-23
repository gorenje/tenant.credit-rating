get '/auth' do
  session[:authenticated] = false
  haml :auth, :layout => false
end

post '/auth' do
  if ENV['SECRET_CODE'] == params[:code]
    session[:authenticated] = true
    redirect '/'
  else
    redirect '/auth'
  end
end
