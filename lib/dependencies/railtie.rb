require 'dependencies/rack_container'
require 'dependencies/rails_loader'
require 'dependencies/controller'

module Dependencies
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
      Dependencies::RackContainer,
      &Dependencies::RailsLoader.new
    )
  end
end
