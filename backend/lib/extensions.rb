class String
  def singularize
    return chop if downcase.end_with? "s"
    self
  end
end
