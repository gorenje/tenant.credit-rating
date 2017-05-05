post '/iban/check' do
  return_json do
    { :r => IBANTools::IBAN.valid?(params[:iban]) }
  end
end

post '/iban/bankname' do
  return_json do
    { :r => BlzSearch.find_bank_name(IBANTools::IBAN.new(params[:iban])) }
  end
end
