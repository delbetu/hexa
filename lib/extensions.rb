require 'shared/errors'

class String
  def singularize
    return chop if downcase.end_with? "s"
    self
  end
end

class Hash
  def symbolize_keys
    transform_keys(&:to_sym)
  end

  def stringify_keys
    transform_keys(&:to_s)
 end
end

class NullObject
  def initialize
    @origin = caller.first
  end

  def __null_origin__
    @origin
  end

  def method_missing(*args, &block)
    self
  end

  def nil?
    true
  end
end

def Maybe(value)
  value.nil? ? NullObject.new : value
end

def assert(condition, message = "Assertion failed")
  raise EndUserError, message, caller unless condition
end

def with_error_handling(error_id = "Error", &block)
  block.call
rescue EndUserError => e
  ActionError(id: error_id, errors: [ e.message ])
rescue => e
  if (env == 'production')
    Raven.capture_exception(e)

    # End user doesn't receive a stacktrace
    ActionError(id: error_id, errors: [
      "An error has occured. "\
      "It's been reported and we will be working on it soon. "\
      "Please try again later."
    ])
  else # test & Development
    raise e # Developer needs to track the issue.
  end
end
