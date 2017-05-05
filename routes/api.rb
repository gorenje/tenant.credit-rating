get '/api/account/:account_id.json' do
  return_json do
    if is_logged_in?
      xcnt, xlookup  = 0,{}
      data = get_account.transactions.group_by do |transaction|
        transaction.booking_date.strftime("%Y%m")
      end.sort_by { |a,_| a.to_i }.map do |month, transactions|
        { "x" => xcnt,
          "y" => transactions.map {|t| t.amount.to_f}.sum.round(2)}.tap do
          xlookup[xcnt] ="%s/%s" % [month[4..6], month[0..3]]
          xcnt+=1
        end
      end
      values = data.map { |h| h["y"] }
      { :data    => data,
        :xlookup => xlookup,
        :ymax    => values.max + 100,
        :ymin    => values.min - 100
      }
    else
      []
    end
  end
end
