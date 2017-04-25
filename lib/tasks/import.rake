namespace :import do
  desc <<-EOF
    Defines the task fubar:snafu:doit
  EOF
  task :from_figo do
    User.all.each do |user|
      puts "Import #{user.name} / #{user.email}"

      user.figo_session.accounts.each do |acc|
        puts "   Found #{acc.account_id}"
        dbacc = Account.where(:figo_account_id => acc.account_id,
                              :user            => user).first_or_create

        dbbank = Bank.where(:figo_bank_id => acc.bank_id).first_or_create

        dbbank.update(:figo_bank_code => acc.bank_code,
                      :figo_bank_name => acc.bank_name)

        dbacc.update(:owner              => acc.owner,
                     :name               => acc.name,
                     :account_type       => acc.type,
                     :currency           => acc.currency,
                     :iban               => acc.iban,
                     :account_number     => acc.account_number,
                     :icon_url           => acc.icon,
                     :bank               => dbbank,
                     :last_known_balance => acc.balance.balance.to_s)

        begin
           acc.transactions.each do |trans|
             dbtrans =
               Transaction.where( :figo_transaction_id => trans.transaction_id,
                                  :account             => dbacc).first_or_create
             dbtrans.update(:name             => trans.name,
                            :amount           => trans.amount.to_s,
                            :currency         => trans.currency,
                            :booking_date     => trans.booking_date,
                            :value_date       => trans.value_date,
                            :booked           => trans.booked,
                            :purpose          => trans.purpose,
                            :transaction_type => trans.type,
                            :booking_text     => trans.booking_text)
           end
        rescue
        end
      end
    end
  end
end
