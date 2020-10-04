# frozen_string_literal: true

require 'fileutils'

def update_shared_fixture(path, http_response)
  content = JSON.parse(http_response.body)
  destination_file = "#{APP_ROOT}/../shared/fixtures/#{path}"
  FileUtils.mkdir_p(Pathname.new(destination_file).dirname)
  File.write(destination_file, JSON.pretty_generate(content))
end
