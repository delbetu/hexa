# Handles operations with templates files
class Templates
  def self.load_erb(name, data)
    ERB
      .new(File.read("lib/erb_templates/#{name}.html.erb"))
      .result_with_hash(data)
  end
end
