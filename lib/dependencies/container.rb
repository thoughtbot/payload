require 'dependencies/factory_definition'
require 'dependencies/service_definition'

module Dependencies
  # Used for configuring and resolving dependencies.
  #
  # Use RackContainer to inject a container into Rack requests.
  class Container
    def initialize(definitions)
      @definitions = definitions
    end

    # Extends or replaces an existing dependency definition.
    #
    # The block will be given the current definition and the container as
    # arguments.
    def decorate(dependency, &block)
      decorated = @definitions.find(dependency).decorate(block)
      define dependency, decorated
    end

    # Defines a factory which can be used to instantiate the dependency. Useful
    # if some dependencies come from the container but others come from runtime
    # state.
    #
    # Resolving the dependency will return an object which responds to `new`.
    # The `new` method will accept remaining dependencies and return the fully
    # resolved dependency from the given block.
    #
    # The block will receive the container. Any arguments to `new` will be
    # added as services on the container.
    def factory(dependency, &block)
      define dependency, FactoryDefinition.new(block)
    end

    # Defines a service which can be fully resolved from the container.
    #
    # The block will receive the container and is expected to return the
    # instantiated service.
    def service(dependency, &block)
      define dependency, ServiceDefinition.new(block)
    end

    # Resolves a dependency. An unknown dependency will result in an
    # UndefinedDependencyError.
    def [](dependency)
      @definitions.find(dependency).resolve(self)
    end

    private

    def define(dependency, definition)
      self.class.new(@definitions.add(dependency, definition))
    end
  end
end
