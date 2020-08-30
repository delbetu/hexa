require 'shared/adapters/users_adapter'
require 'sign_up/domain/user_creator_port'

class UserCreatorAdapter
  extend ::UserCreatorPort

  def self.create(attributes)
    Adapters::Users.create(attributes)
  end

  def self.exists?(email:)
    !Adapters::Users.read(filters: [ { email: email} ]).empty?
  end
end
