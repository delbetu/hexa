class String
  def singularize
    return chop if downcase.end_with? "s"
    self
  end
end

class Hash
  def symbolize_keys
    self.map { |k, v| [k.to_sym, v]  }.to_h
  end
end
