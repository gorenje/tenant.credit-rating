post '/iban/check' do
  content_type :json
  { :r => IBANTools::IBAN.valid?(params[:iban]) }.to_json
end

post '/iban/bankname' do
  content_type :json
  { :r => BlzSearch.find_bank_name(IBANTools::IBAN.new(params[:iban])) }.to_json
end
