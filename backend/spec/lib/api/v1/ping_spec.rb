require 'api_persistence_helper'

describe "/ping" do
  it 'respons with pong' do
    get 'ping'
    expect(last_response).to be_ok
    expect(last_response.body).to match(/pong/)
  end
end
