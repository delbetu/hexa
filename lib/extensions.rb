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
