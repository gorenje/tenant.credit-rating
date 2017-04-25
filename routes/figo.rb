get '/figo/login' do
  puts "Redirecting to: #{$figo_connection.login_url("qweqwe")}"
  redirect $figo_connection.login_url("qweqwe")
end

get '/figo/figo_login' do
  puts params
end

get '/callback' do
  puts params
end
