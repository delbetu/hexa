require 'shared/adapters/users_adapter'

class UserCreatorAdapter
  def self.create(attributes)
    Adapters::Users.create(attributes)
  end

  def self.exists?(email:)
    !Adapters::Users.read(filters: [ { email: email} ]).empty?
  end
end
