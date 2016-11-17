module Atmosphere::UserExt
  extend ActiveSupport::Concern

  included do
    include Atmosphere::TokenAuthenticatable
#    include Atmosphere::JwtAuthenticatable

    has_and_belongs_to_many :security_proxies,
      class_name: '::SecurityProxy'

    has_and_belongs_to_many :security_policies,
      class_name: '::SecurityPolicy'

    around_update :manage_metadata

    attr_accessor :mi_ticket, :jwt_token, :project
  end

  # METADATA lifecycle methods

  # Check if we need to update metadata regarding this user's ATs, if so, perform the task
  def manage_metadata
    login_changed = login_changed?
    yield
    update_appliance_type_metadata if login_changed
  end

  def update_appliance_type_metadata
    appliance_types.select(&:publishable?).each(&:update_metadata)
  end

  module ClassMethods
    def vph_find_or_create(auth)
      user = where(login: auth.info.login).first ||
              where(email: auth.info.email).first
      unless user
        user = new
        user.generate_password
      end

      user.login     = auth.info.login
      user.email     = auth.info.email
      user.full_name = auth.info.full_name
      user.roles     = auth.info.roles
      user.save

      user
    end

    def jwt_find_or_create(auth)

      Rails.logger.debug("Proceeding with auth: #{auth.inspect} of class #{auth.class.to_s}")

      Rails.logger.debug("Searching for email: #{auth['email']}")

      user = find_by(email: auth['email'])

      if user.blank?

        Rails.logger.debug("User not found.")

        user = new
        user.generate_password
      else
        Rails.logger.debug("User found: #{user.inspect}")
      end

      user.login = auth['email']
      user.email = auth['email']
      user.full_name = auth['name']

      Rails.logger.debug("Saving user...")


      user.save

      Rails.logger.debug("User has errors: #{user.errors.inspect}")

      user
    end



  end
end
