# Stores an email confirmation for the given user
class PendingConfirmationPort
  #TODO: implement adapter
  def self.create!(user_id:, roles:)
    OpenStruct.new(id: 777)
  end
end

