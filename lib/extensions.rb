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
