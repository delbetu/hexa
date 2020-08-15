
def update_shared_fixture(path, http_response)
  # TODO: move to support
  # TODO: don't override ids
  content = JSON.parse(http_response.body)
  File.write("#{APP_ROOT}/../shared/fixtures/#{path}", JSON.pretty_generate(content))
end

