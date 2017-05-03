# -*- coding: utf-8 -*-
MenuItems = {
  "Konten" => "/accounts",
  "Bonität" => "/rating",
  "Dienste" => "/services",
}

FigoPublicKey="-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1qB2hmObbCbAM+lc+ggDauoIZReejEimnvrmeqEs0opeTeZiiietoHT1FkB8HjlgCWrh6UimxrRvBwwvNn/4uiVEqxuPb37ozWRj87bp1R3iwhzIGHBMgkibfFf9v3FxEjtY6CgCvOJ/12+AiotL+4jBCwsUWcqui3phq4/C19bQTWaN8u1Q1ABB0SSExcfqH3Ahg6i4pJfDwY+/khb4rgvmqPpb7a0tHiWuWqAMUxfEO/GJVaDV+Bq4k5vfUNirIcazUtmnLhBVSTBcjw7OEDEIHGckwUHs6prKE0kkQD4Xjm06XupuZW8/H+/oPBdHJBr+Ugv5Kzlsst/81BEyoQIDAQAB-----END PUBLIC KEY-----"

RatingFactors = {
  :one => {
    :name => "Number of Accounts",
    :desc => "How many accounts do you have?",
    :proc => Proc.new do |user|
      case cnt = user.accounts.count
        when 0 then [cnt,-3]
        when 1 then [cnt,-1]
        when 2 then [cnt,1]
        when 3 then [cnt,3]
        when 4 then [cnt,2]
        else [cnt,-1]
      end
    end
  },
  :two => {
    :name => "Accounts Positive Balance",
    :desc => "How many accounts do you have that positive cash flow?",
    :proc => Proc.new do |user|
      total_accounts = user.accounts.count
      positive_accounts = user.accounts.where("last_known_balance > 0").count
      cnt = positive_accounts
      case total_accounts - positive_accounts
        when 0 then [cnt, 2]
        when 1 then [cnt, 0]
        when 2 then [cnt,-1]
        when 3 then [cnt,-2]
        when 4 then [cnt,-3]
        else [cnt,-4]
      end
    end
  },
  :three => {
    :name => "Average Transactions per Account",
    :desc => "How many transactions per account on average?",
    :proc => Proc.new do |user|
      case cnt = user.accounts.map { |a| a.transactions.count}.average
        when (0..100) then [cnt, 0]
        when (100..400) then [cnt, 1]
        when (400..800) then [cnt, 2]
        when (800..1000) then [cnt,1]
        when (1000..1200) then [cnt,1]
        else [cnt,-1]
      end
    end
  }
}
