get '/ping' do
  content_type :json
  { value: 'pong!' }.to_json
end
