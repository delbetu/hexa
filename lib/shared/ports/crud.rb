module Ports
  module Crud
    # TODO: remove interface use contracts
    extend Interface
    method :create
    method :read
    method :update
    method :delete
  end
end
