require 'payload/definition_list'
require 'payload/container'
require 'payload/mutable_container'

module Payload
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
      namespace_containers.inject(root_container) do |target, source|
        target.import(source.exports)
      end
    end

    private

    def namespace_containers
      namespace_config_paths.map { |path| load_from(path) }
    end

    def root_container
      load_from(root_config_path).build
    end

    def load_from(path)
      container = MutableContainer.new(Container.new(DefinitionList.new))
      container.instance_eval(IO.read(path), path)
      container
    end

    def root_config_path
      config_path.join('dependencies.rb').to_s
    end

    def namespace_config_paths
      Dir.glob config_path.join('payload/*.rb').to_s
    end

    def config_path
      Rails.root.join('config')
    end
  end
end
