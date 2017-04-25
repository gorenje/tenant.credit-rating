class User < ActiveRecord::Base
  has_many :accounts
  has_many :transactions, :through => :accounts
  has_many :banks, :through => :accounts

  def self.find_or_create_user_by_figo(access_token)
    return if access_token.nil?

    user = Figo::Session.new(access_token).user
    if User.where(:email => user.email).count > 0
      return User.where(:email => user.email).first
    end

    create(:email          => user.email,
           :name           => user.name,
           :address        => user.address,
           :email_verified => user.verified_email,
           :language       => user.language,
           :join_date      => user.join_date,
           :access_token   => access_token)
  end

  def figo_session
    Figo::Session.new(access_token)
  end
end
