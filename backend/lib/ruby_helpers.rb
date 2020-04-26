
######### Allow interface definitions like this: #########
# class CRUDPort
#   extend Interface
#   method :create
#   method :read
#   method :update
#   method :delete
# end
module Interface
  # TODO: When adding an argument to method => *args returns []
  def method(name, key_args: {})
    define_method(name) do |*args|
      raise "Must implement method #{name}(#{key_args})"
    end
  end
end
