# frozen_string_literal: true

require 'shared/authorization/infrastructure/auth_data_provider_adapter'
require 'shared/authorization/authorizer'
require 'shared/adapters/sequel/crud'

module Adapters
  module JobPosts
    extend Adapters::Sequel::Crud
    with(table: :job_posts)
  end
end

# posted_on, company_name, company_website, company_logo, company_location,
# tags = backend contract programming anywhere
# rich text description
# offered_payment
# active: boolean
module Types
  class JobPost < BaseObject
    description 'JobPosts'

    field :id, ID, null: false
    field :posted_on, GraphQL::Types::ISO8601DateTime, null: false
    field :active, Boolean, null: false
    field :company_name, String, null: false
    field :rich_description, String, null: false
  end
end

module Resolvers
  class JobPostsQuery < Resolvers::Base
    type [Types::JobPost], null: true

    def resolve
      Adapters::JobPosts.read
    end
  end
end

module Mutations
  class CreateJobPost < BaseMutation
    null true

    description 'Creates a job post'

    # Input
    argument :posted_on, GraphQL::Types::ISO8601DateTime, required: true
    argument :active, Boolean, required: true
    argument :company_name, String, required: true
    argument :rich_description, String, required: true

    # Output
    field :success, Boolean, null: false
    field :errors, [String], null: true
    field :id, ID, null: true

    def resolve(posted_on:, active:, company_name:, rich_description:)
      # only human resources can create posts
      context[:authorizer].allow_roles('hr')
      created = Adapters::JobPosts.create(
        posted_on: posted_on,
        active: active,
        company_name: company_name,
        rich_description: rich_description
      )

      {
        success: true
      }.merge(created)
    rescue CreateError => e
      {
        success: false,
        errors: e.backtrace
      }
    end
  end

  class UpdateJobPost < BaseMutation
    null true

    description 'Updates a job post'

    # Input
    argument :id, ID, required: true
    argument :posted_on, GraphQL::Types::ISO8601DateTime, required: false
    argument :active, Boolean, required: false
    argument :company_name, String, required: false
    argument :rich_description, String, required: false

    # Output
    field :success, Boolean, null: false
    field :errors, [String], null: true
    field :id, ID, null: false

    def resolve(id:, posted_on: nil, active: nil, company_name: nil, rich_description: nil)
      update_attrs = {
        id: id,
        posted_on: posted_on,
        active: active,
        company_name: company_name,
        rich_description: rich_description
      }.compact
      updated = Adapters::JobPosts.update(update_attrs)

      {
        success: true
      }.merge(updated)
    rescue UpdateError => e
      {
        success: false,
        errors: e.backtrace
      }
    end
  end

  class DeleteJobPost < BaseMutation
    null true

    description 'Deletes a job post'

    # Input
    argument :id, ID, required: true

    # Output
    field :success, Boolean, null: false
    field :errors, [String], null: true
    field :id, ID, null: false

    def resolve(id:)
      deleted = Adapters::JobPosts.delete(
        id: id
      )

      {
        success: true
      }.merge(deleted)
    rescue DeleteError => e
      {
        success: false,
        errors: e.backtrace
      }
    end
  end
end
