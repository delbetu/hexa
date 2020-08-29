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
  template = templates[template_name] || index_template

  ERB.new(template[:erb]).result_with_hash(template[:data])
end

# for each file under templates directory
# returns
# {
#   filename: {
#     erb: File.read('lib/erb_templates/filename.html.erb'),
#     data: YAML.load_file('lib/erb_templates/filename.data.yml')
#   }
# }
def templates
  template_names.inject({}) do |acum, filename|
    acum.merge(
      filename => {
        erb: File.read("#{TEMPLATES_DIR}/#{filename}.html.erb"),
        data: YAML.load_file("#{TEMPLATES_DIR}/#{filename}.data.yml")
      }
    )
  end
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
