namespace :import do
  desc <<-EOF
    Import all banks supported by figo.
  EOF
  task :figo_supported_stuff do
    (FigoHelper.get_banks + [FigoDemoBank]).each do |bnk|
      FigoSupportedBank.where(:bank_code => bnk["bank_code"]).
        first_or_create.
        update(:bank_name    => bnk["bank_name"],
               :advice       => bnk["advice"],
               :details_json => bnk.to_json)
    end

    FigoHelper.get_services.each do |srv|
      FigoSupportedService.where(:bank_code => srv["bank_code"]).
        first_or_create.
        update(:name         => srv["name"],
               :advice       => srv["advice"],
               :details_json => srv.to_json)
    end
  end

  desc <<-EOF
    Import all accounts from the general user.
  EOF
  task :from_figo_general do
    FigoHelper.start_session.accounts.each do |acc|
      next if acc.iban.blank?

      puts "Looking for #{acc.iban}"
      dbacc = Account.where(:iban => acc.iban).first
      next if dbacc.nil?

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
                   :last_known_balance => acc.balance.balance.to_s,
                   :save_pin           => acc.bank.save_pin,
                   :sepa_creditor_id   => acc.bank.sepa_creditor_id)

      begin
        puts "Getting transactions for #{dbacc.iban}"
        acc.transactions(dbacc.newest_transaction_id).each do |trans|
          dbtrans =
            FigoTransaction.
            where( :transaction_id => trans.transaction_id,
                   :account        => dbacc).first_or_create

          dbtrans.update( :name             => trans.name,
                          :amount           => trans.amount.to_s,
                          :currency         => trans.currency,
                          :booking_date     => trans.booking_date,
                          :value_date       => trans.value_date,
                          :booked           => trans.booked,
                          :purpose          => trans.purpose,
                          :transaction_type => trans.type,
                          :booking_text     => trans.booking_text)
        end
      rescue Exception => e
        puts e.message
      end
    end
  end

  desc <<-EOF
    Import account and transaction data for all users.
  EOF
  task :from_figo_connected do
    User.all.each do |user|
      puts "Import #{user.name} / #{user.email}"
      next if user.figo_session.nil?

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
                     :last_known_balance => acc.balance.balance.to_s,
                     :save_pin           => acc.bank.save_pin,
                     :sepa_creditor_id   => acc.bank.sepa_creditor_id)

        begin
          acc.transactions(dbacc.newest_transaction_id).each do |trans|
            dbtrans =
              FigoTransaction.
              where( :transaction_id => trans.transaction_id,
                     :account        => dbacc).first_or_create

            dbtrans.update( :name             => trans.name,
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
