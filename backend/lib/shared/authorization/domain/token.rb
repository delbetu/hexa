require 'jwt'

class Token
  def self.hmac_secret
    ENV.fetch('JWT_SECRET', '')
  end

  # gets data return token
  def self.encode(data)
    JWT.encode(data, hmac_secret, 'HS256')
  end

  # gets token returns data
  def self.decode(token)
    JWT.decode(token, hmac_secret, true, {algorithm: 'HS256'})
  end
end
