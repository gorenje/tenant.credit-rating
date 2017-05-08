# -*- coding: utf-8 -*-
MenuItems = {
  "Konten" => "/accounts",
  "Bonität" => "/rating",
}

FigoPublicKey="-----BEGIN PUBLIC KEY-----MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1qB2hmObbCbAM+lc+ggDauoIZReejEimnvrmeqEs0opeTeZiiietoHT1FkB8HjlgCWrh6UimxrRvBwwvNn/4uiVEqxuPb37ozWRj87bp1R3iwhzIGHBMgkibfFf9v3FxEjtY6CgCvOJ/12+AiotL+4jBCwsUWcqui3phq4/C19bQTWaN8u1Q1ABB0SSExcfqH3Ahg6i4pJfDwY+/khb4rgvmqPpb7a0tHiWuWqAMUxfEO/GJVaDV+Bq4k5vfUNirIcazUtmnLhBVSTBcjw7OEDEIHGckwUHs6prKE0kkQD4Xjm06XupuZW8/H+/oPBdHJBr+Ugv5Kzlsst/81BEyoQIDAQAB-----END PUBLIC KEY-----"

BlzSearchUrls = {}
BlzSearchUrls["DE"]="https://www.bundesbank.de/Navigation/DE/Service/Suche_BLZ/Erweitert/erweiterte_blz_suche_node.html"

TransactionFormats = {
  "mt940"    => ["Mt940Handler",    "MT 940 Format"],
  "camt"     => ["UnknownFormat",   "CAMT Format"],
  "csvmt940" => ["CsvMt940Handler", "CSV MT940 Format"],
  "csvcamt"  => ["UnknownFormat",   "CSV CAMT Format"],
}

BankLoginURLs = {
  "10050000" => "https://www.berliner-sparkasse.de/de/home.html"
}
