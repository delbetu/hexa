module UserCreator
  def self.create(user_attributes)
    user_attributes
  end

  def self.exists?(email:)
    false
  end
end
