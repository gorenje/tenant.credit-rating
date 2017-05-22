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

      dbbank = Bank.where(:figo_bank_id => acc.bank_id).
        first_or_create.tap do |bnk|
        bnk.update(:figo_bank_code => acc.bank_code,
                   :figo_bank_name => acc.bank_name)
      end

      dbacc.update_from_figo_account(acc, dbbank)

      begin
        puts "Getting transactions for #{dbacc.iban}"
        acc.transactions(dbacc.newest_transaction_id).each do |trans|
          FigoTransaction.
            where( :transaction_id => trans.transaction_id,
                   :account        => dbacc).
            first_or_create.update_from_figo_transaction(trans)
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

        dbbank = Bank.where(:figo_bank_id => acc.bank_id).
          first_or_create.tap do |bnk|
          bnk.update(:figo_bank_code => acc.bank_code,
                     :figo_bank_name => acc.bank_name)
        end

        dbacc.update_from_figo_account(acc, dbbank)

        begin
          acc.transactions(dbacc.newest_transaction_id).each do |trans|
            FigoTransaction.
              where( :transaction_id => trans.transaction_id,
                     :account        => dbacc).
              first_or_create.update_from_figo_transaction(trans)
          end
        rescue Exception => e
          puts e.message
        end
      end
    end
  end
end
