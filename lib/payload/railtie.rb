require 'payload/rack_container'
require 'payload/rails_loader'
require 'payload/controller'

module Payload
  # Automatically loads and injects dependencies into the Rack environment for
  # Rails applications.
  #
  # Requiring this file is enough to:
  #
  # * Load dependency definitions from config/dependencies.rb using
  #   {RailsLoader} and {MutableContainer}.
  # * Provide a {Container} in each Rack request.
  class Railtie < ::Rails::Railtie
    config.app_middleware.use(
      Payload::RackContainer,
      &Payload::RailsLoader
    )
  end
end
