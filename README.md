Before deploying to Heroku, you need to generate key/IV for the encryption
of the credentials.

Generate a new cred key with:

    rake shell
    prompt> cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    prompt> cipher.encrypt
    prompt> Base64.encode64(cipher.random_key) ## value for CRED_KEY_BASE64
    prompt> Base64.encode64(cipher.random_iv) ## value for CRED_IV_BASE64
