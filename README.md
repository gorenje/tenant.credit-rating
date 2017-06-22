Credit Rating based on Account data
===

Sinatra app for handling account data to generate a credit rating.

Prerequistes
---

Before deploying to Heroku, you need to generate key/IV for the encryption
of the credentials.

Generate a new cred key with:

    rake shell
    prompt> cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    prompt> cipher.encrypt
    prompt> Base64.encode64(cipher.random_key) ## value for CRED_KEY_BASE64
    prompt> Base64.encode64(cipher.random_iv) ## value for CRED_IV_BASE64


Generating Private/Public key pair suitable for password encryption:

    openssl genrsa -out mykey.pem 2048
    openssl rsa -in mykey.pem -pubout > mykey.pub

Or using ruby:

    key = OpenSSL::PKey::RSA.generate(2048)
    key.export # private key
    key.public_key.export

Features
---

  1. Credit Rating History
  2. Bank Account data import
  3. Bank Account transaction data automatic import
  4. Credit Rating Badge

Local testing
---

Generate a ```.env``` file by running:

    bundle exec rake appjson:to_dotenv

This will do it's best to generate test environment including setting
up the various ciphers and keys.

Bootstrapping
---

Need to run the following tasks to initialise the app:

    rake import:figo_supported_stuff

After that, the following tasks should be run regularly:

    rake import:figo_supported_stuff # once a day
    rake import:from_figo # every 10 mins
    rake ratings:compute # every 10 mins

These takes ensure things are up-to-date and that transactions are
retrieved as soon as they become available.
