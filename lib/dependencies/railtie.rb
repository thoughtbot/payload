require 'dependencies/rack_container'
require 'dependencies/rails_loader'

module Dependencies
  # Automatically loads and injects dependencies into the Rack environment for
  # Rails applications.
  #
  # Requiring this file is enough to:
  #
  # * Load dependency definitions from config/dependencies.rb.
  # * Provide env[:dependencies] as a container for each request.
  class Railtie < ::Rails::Railtie
    config.app_middleware.use(
      Dependencies::RackContainer,
      &Dependencies::RailsLoader.new
    )
  end
end
