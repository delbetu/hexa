# By convention EndUserError is used to encapsulate errors that need to be shown to the end user.
class EndUserError < StandardError; end
class CreateError < EndUserError; end
class UpdateError < EndUserError; end
class DeleteError < EndUserError; end

