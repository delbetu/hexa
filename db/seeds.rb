require_relative '../lib/load_gems'
require 'shared/authorization/domain/password'
Sequel.extension :core_extensions

pwd = Password.encrypt('pass123!')
users = DB[:users]

users.insert(name: 'Batman', email: 'bruce.wayne@gotham.com', password: pwd, roles: "[\"hr\"]")
users.insert(name: 'Robin', email: 'dick.grayson@gotham.com', password: pwd, roles: "[\"hr\"]")
users.insert(name: 'Batgirl', email: 'barbara.gordon@gotham.com', password: pwd, roles: "[\"hr\"]")
users.insert(name: 'Commissioner', email: 'james.gordon@gotham.com', password: pwd, roles: "[\"hr\"]")
users.insert(name: 'Joker', email: 'who.knows@gotham.com', password: pwd, roles: "[\"hr\"]")
puts '5 Users inserted'

job_posts = DB[:job_posts]
job_posts.insert(
  posted_on: '2020-10-18',
  active: true,
  company_name: 'Wayne Corp.',
  rich_description: %(
    <h1> Butler </h1>
    <br/>
    <p> Alfred coffe is terrible! I need a new butler.</p>
  )
)
