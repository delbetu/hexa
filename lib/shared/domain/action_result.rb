class SuccessResult < SimpleDelegator
  def success?
    true
  end

  def errors
    []
  end

  def id
    __getobj__.id || '-'
  end
end

class ErrorResult < SimpleDelegator
  def success?
    false
  end

  def id
    __getobj__.id || '-'
  end
end

def ActionSuccess(attrs)
  SuccessResult.new(OpenStruct.new(attrs))
end

def ActionError(attrs)
  ErrorResult.new(OpenStruct.new(attrs))
end
