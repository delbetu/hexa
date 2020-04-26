require 'api_persistence_helper'

describe "get /users" do
  it 'list users' do
    Persistence::Users.create(build_user.with(name: 'Batman').build)
    Persistence::Users.create(build_user.with(name: 'Penguin', email: 'penguin@gotham.com').build)

    get '/users'

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 0, 'attributes', 'name')).to eq('Batman')
    expect(content.dig('data', 1, 'attributes', 'name')).to eq('Penguin')

    File.write("#{APP_ROOT}/../shared/fixtures/api/users/list/success.json", JSON.pretty_generate(content))
  end

  it 'list users' do
    Persistence::Users.create(build_user.with(name: 'Batman').build)
    Persistence::Users.create(build_user.with(name: 'Penguin', email: 'penguin@gotham.com').build)

    get '/users?filters[0]=name=Batman&filters[1]=email=batman@gotham.com'

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 0, 'attributes', 'name')).to eq('Batman')
    expect(content.dig('data', 1, 'attributes', 'name')).to eq('Penguin')

    File.write("#{APP_ROOT}/../shared/fixtures/api/users/list/success.json", JSON.pretty_generate(content))
  end
end

describe 'get /users/:id' do
  it 'find a user' do
    batman = Persistence::Users.create(build_user.with(name: 'Batman').build)
    Persistence::Users.create(build_user.with(name: 'Penguin', email: 'penguin@gotham.com').build)

    get "/users/#{batman[:id]}"

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 'attributes', 'name')).to eq('Batman')

    File.write("#{APP_ROOT}/../shared/fixtures/api/users/find/success.json", JSON.pretty_generate(content))
  end
end

describe 'patch /users/:id' do
  it 'updates a user' do
    batman = Persistence::Users.create(build_user.with(name: 'Batman').build)
    Persistence::Users.create(build_user.with(name: 'Penguin', email: 'penguin@gotham.com').build)

    patch "/users/#{batman[:id]}", user: { name: 'Bruce' }

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 'attributes', 'name')).to eq('Bruce')

    File.write("#{APP_ROOT}/../shared/fixtures/api/users/update/success.json", JSON.pretty_generate(content))
  end
end

describe 'post /users' do
  it 'creates a user' do
    batman = build_user.with(name: 'Batman').build

    # TODO: add test support helper: token_with_permissions('sign_up')
    header 'Authorization', App::Token.encode({'permissions' => ['sign_up']})
    post '/users', user: batman

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 'type')).to eq('users')
    expect(content.dig('data', 'attributes', 'name')).to eq('Batman')

    File.write("#{APP_ROOT}/../shared/fixtures/api/users/create/success.json", JSON.pretty_generate(content))
  end
end

describe 'delete /users' do
  it 'deletes a user' do
    batman = Persistence::Users.create(build_user.with(name: 'Batman').build)

    delete "/users/#{batman[:id]}"

    expect(last_response).to be_ok
    content = JSON.parse(last_response.body)
    expect(content.dig('data', 'type')).to eq('users')
    expect(content.dig('data', 'id')).to eq(batman[:id].to_s)
    expect(content.dig('data', 'attributes', 'name')).to eq(batman[:name])

    File.write("#{APP_ROOT}/../shared/fixtures/api/users/delete/success.json", JSON.pretty_generate(content))
  end
end
