require 'erb'
require 'yaml'

#########################################################
# templates directory must have two files per template. #
# One with .html.erb extension and other with .data.yml #
#########################################################
TEMPLATES_DIR = "lib/erb_templates/".freeze

get '/template_preview' do
  return 403 if env == 'production'
  template_name = Maybe(params[:name])

  template = if template_exists?(template_name)
    { erb: load_erb(template_name), data: load_data(template_name) }
  else
    index_template
  end

  ERB.new(template[:erb]).result_with_hash(template[:data])
end

def template_exists?(filename)
  template_names.include?(filename)
end

def load_erb(filename)
  File.read("#{TEMPLATES_DIR}/#{filename}.html.erb")
end

def load_data(filename)
  YAML.load_file("#{TEMPLATES_DIR}/#{filename}.data.yml")
end

# Extract the name of the templates without extensions
def template_names
  Dir["#{TEMPLATES_DIR}*.html.erb"].map { |f| File.basename(f, ".html.erb") }
end

# Returns a list of links for existing templates
def index_template
  index_template = <<-TEMPLATE
    <ul>
      <% names.each do |name| %>
        <li>
          <a href="/template_preview?name=<%=name%>"><%= name %></a>
        </li>
      <% end %>
    <ul>
  TEMPLATE
  {
    erb: index_template,
    data: { names: template_names }
  }
end
