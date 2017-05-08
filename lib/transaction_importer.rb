require 'csv'
require 'cmxl'

module TransactionImporter
  extend self

  class Handler
    attr_reader :account

    def initialize(account)
      @account = account
    end
  end

  class UnknownFormat < Handler
    def import(data)
      raise ErrorPage::FormatNotSupported.new("Unknown Format")
    end
  end

  class CsvMt940Handler < Handler
    def import(data)
      raise ErrorPage::FormatNotSupported.new("Unsupported Format: CSV MT940")

      CSV.new(file_data.force_encoding('ISO-8859-1'),
              :headers => :first_line, :col_sep => ";", :quote_char => '"').
        each do |a|

      end
    end
  end

  class Mt940Handler < Handler
    def import(data)
      Cmxl.parse(data, :encoding => "ISO-8859-1").each do |stmt|
        stmt.transactions.each do |trans|
          if cb = stmt.closing_balance
            @account.update(:currency           => cb.currency,
                            :last_known_balance => cb.amount)
          end

          dbtrans = Mt940Transaction.
            where( :transaction_id => trans.sha,
                   :account        => @account).first_or_create

          dbtrans.update( :name         => trans.name,
                          :amount       => trans.sign * trans.amount,
                          :booking_date => trans.date,
                          :value_date   => trans.entry_date,
                          :extras       => trans.sub_fields,
                          :booking_text => trans.description,
                          :purpose      => trans.information,
                          :currency     => @account.currency,
                          :booked       => true)
        end
      end
    end
  end

  def handler_for(format)
    eval((TransactionFormats[format] || ["UnknownFormat"]).first)
  end
end
