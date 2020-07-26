class UsersSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :email
end

# TODO: Filter, pagination, sorting
get '/users' do
  users = Persistence::Users.read.map { |u| OpenStruct.new(u)}
  UsersSerializer.new(users).serialized_json
end

get '/users/:id' do |id|
  user = Persistence::Users.read(filters: [id: id]).map { |u| OpenStruct.new(u) }.first
  UsersSerializer.new(user).serialized_json
end

patch '/users/:id' do |id|
  updated_user = Persistence::Users.update(params[:user].merge(id: id))
  UsersSerializer.new(OpenStruct.new(updated_user)).serialized_json
end

delete '/users/:id' do |id|
  deleted_user = Persistence::Users.delete(id: id)
  UsersSerializer.new(OpenStruct.new(deleted_user)).serialized_json
end

error do
  # Server error 5xx
  {
    status: 500,
    errors: [
      {
        code: '5xx',
        title: "Not Found",
        detail: "Entity not found"
      }
    ],
  }.to_json
end

not_found do
  # Client error 4xx
  {
    status: 404,
    errors: [
      {
        code: '4xx',
        title: "Not Found",
        detail: "Entity not found"
      }
    ],
  }.to_json
end
