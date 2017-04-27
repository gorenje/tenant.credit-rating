get '/add_account' do
  haml :add_account, :layout => false
end

post '/add_account' do
  puts params
  haml :add_account, :layout => false
end
