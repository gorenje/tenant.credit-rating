get '/api/account/:account_id.json' do
  return_json do
    if is_logged_in?
      xcnt, xlookup  = -1,{}
      data = [{ "name" => "Ingoing",  "color" => "green",     "data" => [], },
              { "name" => "Outgoing", "color" => "red",       "data" => [], },
              { "name" => "Total",    "color" => "steelblue", "data" => [] }]

      get_account.transactions.group_by do |transaction|
        transaction.booking_date.strftime("%Y%m")
      end.sort_by { |a,_| a.to_i }.map do |month, transactions|
        xcnt+=1
        xlookup[xcnt] = "%s/%s" % [month[4..6], month[0..3]]

        data[0]["data"] << { "x" => xcnt,
          "y" => (transactions.select(&:credit?).
                  map { |t| t.amount.to_f }.sum.round(2))
        }
        data[1]["data"] << { "x" => xcnt,
          "y" => (transactions.select(&:debit?).
                  map { |t| t.amount.to_f }.sum.round(2))
        }
        data[2]["data"] << { "x" => xcnt,
          "y" => transactions.map {|t| t.amount.to_f}.sum.round(2)
        }
      end

      values = data.map { |d| d["data"].map { |e| e["y"] }}.flatten
      { :data    => data,
        :xlookup => xlookup,
        :ymax    => values.max + 500,
        :ymin    => values.min - 500
      }
    else
      []
    end
  end
end

get '/api/account/atm/:account_id.json' do
  return_json do
    if is_logged_in?
      xcnt, xlookup  = -1,{}
      data = [{ "name" => "Ingoing",  "color" => "green",     "data" => [], },
              { "name" => "Outgoing", "color" => "red",       "data" => [], },
              { "name" => "Total",    "color" => "steelblue", "data" => [] }]

      get_account.transactions.select(&:atm?).
        group_by do |transaction|
        transaction.booking_date.strftime("%Y%m")
      end.sort_by { |a,_| a.to_i }.map do |month, transactions|
        xcnt+=1
        xlookup[xcnt] = "%s/%s" % [month[4..6], month[0..3]]

        data[0]["data"] << { "x" => xcnt,
          "y" => (transactions.select(&:credit?).
                  map { |t| t.amount.to_f }.sum.round(2))
        }
        data[1]["data"] << { "x" => xcnt,
          "y" => (transactions.select(&:debit?).
                  map { |t| t.amount.to_f }.sum.round(2))
        }
        data[2]["data"] << { "x" => xcnt,
          "y" => transactions.map {|t| t.amount.to_f}.sum.round(2)
        }
      end

      values = data.map { |d| d["data"].map { |e| e["y"] }}.flatten
      { :data    => data,
        :xlookup => xlookup,
        :ymax    => values.max + 500,
        :ymin    => values.min - 500
      }
    else
      []
    end
  end
end
