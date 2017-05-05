get '/api/account/:filter/:account_id.json' do
  return_json do
    if is_logged_in?
      xcnt, xlookup  = -1,{}
      data = [{ "name" => "Ingoing",  "color" => "green",     "data" => [], },
              { "name" => "Outgoing", "color" => "red",       "data" => [], },
              { "name" => "Total",    "color" => "steelblue", "data" => []  }]

      get_account.
        cluster_transactions_by_month(params[:filter]).
        sort_by { |a,_| a.to_i }.
        each do |month, details|

        xcnt += 1
        xlookup[xcnt] = "%s/%s" % [month[4..6], month[0..3]]

        data[0]["data"] << { "x" => xcnt,
          "y" => details["credit"].map(&:to_f).sum.round(2)
        }
        data[1]["data"] << { "x" => xcnt,
          "y" => details["debit"].map(&:to_f).sum.round(2)
        }
        data[2]["data"] << { "x" => xcnt,
          "y" => details["all"].map(&:to_f).sum.round(2)
        }
      end

      values = data.map { |d| d["data"].map { |e| e["y"] }}.flatten
      ymax,ymin = values.max || 0.0, values.min || 0.0
      { :data    => data,
        :xlookup => xlookup,
        :ymax    => ymax > 0 ? ymax + (ymax*0.1) : ymax - (ymax*0.1),
        :ymin    => ymin > 0 ? ymin - (ymin*0.1) : ymin + (ymin*0.1)
      }
    else
      []
    end
  end
end

get '/api/rating/:eid.json' do
  return_json do
    user = User.find_by_external_id(params[:eid])
    data = [{ "name" => "Rating",  "color" => "green", "data" => [] }]

    xcnt, xlookup  = -1,{}
    user.rating_histories.sort_by(&:id).each do |rating|
      xcnt += 1
      xlookup[xcnt] = rating.created_at.to_date
      data[0]["data"] << { "x" => xcnt, "y" => rating.score }
    end

    values = data.map { |d| d["data"].map { |e| e["y"] }}.flatten
    ymax,ymin = values.max || 0.0, values.min || 0.0
    { :data    => data,
      :xlookup => xlookup,
      :ymax    => ymax > 0 ? ymax + (ymax*0.1) : ymax - (ymax*0.1),
      :ymin    => ymin > 0 ? ymin - (ymin*0.1) : ymin + (ymin*0.1)
    }
  end
end
