get '/dopayment/but/doesnt/work' do
  acc          = Account.find(78)
  payment      = acc.figo_payment_for(5)
  figo_payment = acc.user.start_figo_session.add_payment(payment)
  task         = acc.user.start_figo_session.
    submit_payment(figo_payment, nil, nil, nil)
end
