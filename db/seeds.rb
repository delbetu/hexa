require 'bcrypt'
Sequel.extension :core_extensions

pwd = BCrypt::Password.create('pass123!')
users = DB[:users]

users.insert(name: 'Batman', email: 'bruce.wayne@gotham.com', password: pwd, roles: ['hr'])
users.insert(name: 'Robin', email: 'dick.grayson@gotham.com', password: pwd, roles: ['hr'])
users.insert(name: 'Batgirl', email: 'barbara.gordon@gotham.com', password: pwd, roles: ['hr'])
users.insert(name: 'Commissioner', email: 'james.gordon@gotham.com', password: pwd, roles: ['hr'])
users.insert(name: 'Joker', email: 'who.knows@gotham.com', password: pwd, roles: ['hr'])
puts '5 Users inserted'
