class User < ActiveRecord::Base
  has_many :accounts
  has_many :transactions, :through => :accounts
  has_many :banks, :through => :accounts

  include ModelHelpers::CredentialsHelper

  def self.find_or_create_user_by_figo(access_token)
    return if access_token.nil?

    user = Figo::Session.new(access_token).user
    if User.where(:email => user.email).count > 0
      return User.where(:email => user.email).first.tap do |user|
        user.figo_access_token = access_token
      end
    end

    create(:email          => user.email,
           :name           => user.name,
           :address        => user.address,
           :email_verified => user.verified_email,
           :language       => user.language,
           :join_date      => user.join_date).tap do |user|
      user.figo_access_token = access_token
    end
  end

  def figo_session
    Figo::Session.new(creds["access_token"])
  end

  def login_token=(val)
    self.creds = self.creds.merge("login_token" => val)
  end

  def figo_access_token=(val)
    self.creds = self.creds.merge("access_token" => val)
  end

  def password=(val)
    self.creds = self.creds.merge("pass_hash" => Digest::SHA512.hexdigest(val))
  end

  def password_match?(val)
    c = self.creds
    val && c &&
      c["pass_hash"] && Digest::SHA512.hexdigest(val) == c["pass_hash"]
  end
end
