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

def User

end

module ParseHelpers
  def parse_email(email)
    regexp = /^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/
    raise ArgumentError, "Malformed email" unless email.match(regexp)
    email
  end

  def parse_password(password)
    # TODO: check that password must be encoded
    password
  end

  def parse_name(name)
    # TODO: not numbers
    # TODO: max length 100
    name
  end

  def parse_roles(roles)
    # TODO: roles is an array of strings
    # TODO: reject entries that are not present in available roles
    roles
  end
end

module Domain
  # Struct implements to_h
  # TODO:
  User = Struct.new(:email, :password, :name, :roles, keyword_init: true) do
    extend ParseHelpers

    # ensures that user credentials must meet the domain constraints (data and structural)
    def self.parse(email:, password: "", name:, roles: [])
      new(
        email: parse_email(email),
        password: parse_password(password),
        name: parse_name(name),
        roles: parse_roles(roles)
      )
    end

    def [](key)
      to_h[key]
    end
  end
end

def User(attributes)
  # TODO: extend hash to implement symbolize_keys (same as rails does)
  symbolic_hash = attributes.map { |k, v| [k.to_sym, v]  }.to_h
  Domain::User.parse(symbolic_hash)
end


post '/users' do
  begin
    # TODO: Move to user_creation_flow
    # authorization
    decoded_token = App::Token.decode(request.env['HTTP_AUTHORIZATION'])
    permissions = decoded_token[0]['permissions']
    raise Ports::Authorizer::NotAuthorizedError unless permissions.include?('sign_up')

    # parsing
    parsed_user = User(params[:user])

    # error_handling

  new_user = Persistence::Users.create(parsed_user.to_h)
  UsersSerializer.new(OpenStruct.new(new_user)).serialized_json
  end
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
