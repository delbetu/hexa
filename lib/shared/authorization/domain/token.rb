# frozen_string_literal: true

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
    return '' unless token

    JWT.decode(token, hmac_secret, true, { algorithm: 'HS256' }).first
  end
end
