require 'dependencies/empty_definition_list'
require 'dependencies/definition_list'
require 'dependencies/container'
require 'dependencies/mutable_container'

module Dependencies
  # Loads dependencies from config/dependencies.rb in Rails applications.
  #
  # Used by {Railtie} to provide a Rails dependency loader to {RackContainer}.
  class RailsLoader
    # @api private
    def self.to_proc
      lambda { load }
    end

    # Load dependencies from outside a Rails request.
    # @example
    #   RailsLoader.load[:example_service]
    # @return [Container] dependencies from config/dependencies.rb
    def self.load
      new.load
    end

    # @api private
    def load
      container = MutableContainer.new(
        Container.new(
          DefinitionList.new(
            EmptyDefinitionList.new
          )
        )
      )
      container.instance_eval(config, config_path)
      container.build
    end

    private

    def config
      IO.read(config_path)
    end

    def config_path
      Rails.root.join('config', 'dependencies.rb').to_s
    end
  end
end
