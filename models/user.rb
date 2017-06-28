class User < ActiveRecord::Base
  has_many :accounts
  has_many :transactions, :through => :accounts
  has_many :banks, :through => :accounts
  has_many :rating_histories
  has_one :rating

  include ModelHelpers::CredentialsHelper

  def self.generate_random_email
    100.times do
      email = SecureRandom.hex + "@figo.mieterbonitaet.de"
      return email if where(:email => email).count == 0
    end
  end

  def self.generate_random_id
    100.times do
      id = SecureRandom.random_number(2147483647)
      return id if where(:id => id).count == 0
    end
  end

  def self.create_random_new_user
    create(:id             => generate_random_id,
           :email          => generate_random_email,
           :name           => "Random User",
           :address        => "",
           :email_verified => true,
           :language       => "",
           :join_date      => DateTime.now,
           :confirm_token  => nil,
           :has_confirmed => true)
  end

  def self.find_by_external_id(eid)
    _,p,l,v = Base64::decode64(eid).split(/\|/)
    v =~ /.{#{p.to_i}}(.{#{l.to_i}})/
    find_by_id($1)
  end

  def update_rating
    rateng  = RatingEngine.new(self)
    details = { :details => rateng.tablize_ratings.to_json }
    score   = rateng.rating

    if rating.nil?
      Rating.create(:user => self, :score => score, :details => details)
      reload
    end

    if rating.score != score || rating_histories.count == 0
      rating_histories <<
        RatingHistory.create(:user    => self,
                             :score   => rating.score,
                             :details => rating.details)
      rating.update(:score => score, :details => details)
    end
  end

  def external_id
    l = id.to_s.length
    p = rand(18-l)+1
    r = ("%020d" % rand.to_s.gsub(/^.+[.]/,'').to_i).
      gsub(/(.{#{p}}).{#{l}}(.+)/, "\\1#{id}\\2")
    Base64::encode64("eid|%03d|%03d|%s" % [p,l,r]).strip
  end

  def login_token=(val)
    self.creds = self.creds.merge("login_token" => val)
  end

  def figo_access_token
    creds["access_token"]
  end

  def figo_access_token=(val)
    self.creds = self.creds.merge("access_token" => val)
  end

  def password=(val)
    self.creds = self.creds.merge("pass_hash" => Digest::SHA512.hexdigest(val))
  end

  def has_figo_account?
    !!self.creds["figo_password"]
  end

  def email_confirm_token_matched?(token, slt)
    confirm_token == AdtekioUtilities::Encrypt.generate_sha512(slt, token)
  end

  def to_hash
    JSON.parse(to_json)
  end

  def update_accounts_from_figo
    start_figo_session.accounts.each do |acc|
      puts "   Found #{acc.account_id}"
      dbacc = Account.where(:figo_account_id => acc.account_id,
                            :user            => self).first_or_create

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

  def password_match?(val)
    c = self.creds
    val && c &&
      c["pass_hash"] && Digest::SHA512.hexdigest(val) == c["pass_hash"]
  end

  def create_or_update_figo_account
    return if self.creds["figo_recovery_password"]

    figo_password = PasswordGenerator.generate_password
    recovery_password = $figo_connection.
      create_user(name, email, figo_password)["recovery_password"]

    self.creds = self.creds.
      merge({"figo_recovery_password" => recovery_password,
             "figo_password"          => figo_password})
  end

  def start_figo_session
    data = $figo_connection.credential_login(email,self.creds["figo_password"])
    Figo::Session.new(data["access_token"])
  end

  def generate_email_token(more_args = {})
    {}.tap do |p|
      p[:token]         = AdtekioUtilities::Encrypt.generate_token
      p[:salt]          = AdtekioUtilities::Encrypt.generate_salt
      p[:confirm_token] = AdtekioUtilities::Encrypt.generate_sha512(p[:salt], p[:token])

      # so the encoding of the email isnt always the same
      estr = { :email => email, :salt => p[:salt] }.merge(more_args).to_json
      p[:email] = AdtekioUtilities::Encrypt.encode_to_base64(estr)
    end
  end

  def generate_email_confirmation_link
    params = generate_email_token

    update(:salt             => nil,
           :has_confirmed    => false,
           :confirm_token    => params[:confirm_token])

    "#{$hosthandler.dashboard.url}/user/emailconfirm?%s" % {
      :email => params[:email], :token => params[:token] }.to_query
  end

  def last_transaction_date
    accounts.map(&:transactions).map do |trans|
      tran = trans.order(:booking_date).last
      tran && tran.booking_date
    end.compact.sort.last
  end

  def transactions_by_month(filter = nil)
    accounts.map(&:transactions).map do |trans|
      trans.filter(filter)
    end.flatten.group_by do |tran|
      tran.booking_date.strftime("%Y%m")
    end
  end
end
