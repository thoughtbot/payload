require 'payload/definition_list'
require 'payload/factory_resolver'
require 'payload/service_resolver'

module Payload
  # Used for configuring and resolving dependencies.
  #
  # @see Railtie Railtie to configure and use dependencies in Rails
  #   applications.
  # @see RackContainer RackContainer to inject a container into Rack requests.
  # @see MutableContainer MutableContainer to define dependencies in
  #   configuration files.
  class Container
    # Used internally by {RailsLoader}.
    #
    # @api private
    # @param [DefinitionList] definitions previously defined definitions.
    def initialize(definitions = DefinitionList.new)
      @definitions = definitions
    end

    # Extends or replaces an existing dependency definition.
    #
    # @param dependency [Symbol] the name of the dependency to decorate.
    # @yield [Container] the resolved container.
    # @yieldreturn the decorated instance.
    def decorate(dependency, &block)
      self.class.new(@definitions.decorate(dependency, block))
    end

    # Defines a factory which can be used to instantiate the dependency. Useful
    # if some dependencies come from the container but others come from runtime
    # state.
    #
    # Resolving the dependency will return an object which responds to `new`.
    # The `new` method will accept remaining dependencies and return the fully
    # resolved dependency from the given block.
    #
    # @param dependency [Symbol] the name of the dependency to define.
    # @yield [Container] the resolved container; any arguments to `new` will be
    #   added to the container.
    # @yieldreturn an instance of your dependency.
    def factory(dependency, &block)
      define dependency, FactoryResolver.new(block)
    end

    # Defines a service which can be fully resolved from the container.
    #
    # @param dependency [Symbol] the name of the dependency to define.
    # @yield [Container] the resolved container.
    # @yieldreturn the instantiated service.
    def service(dependency, &block)
      define dependency, ServiceResolver.new(block)
    end

    # Resolves and returns dependency.
    #
    # @param dependency [Symbol] the name of the dependency to resolve.
    # @raise [UndefinedDependencyError] for undefined dependencies.
    def [](dependency)
      @definitions.find(dependency).resolve(self)
    end

    # Exports dependencies which can be imported into another container.
    #
    # Used internally by {MutableContainer}. Use {MutableContainer#export}.
    #
    # @api private
    # @param names [Array<Symbol>] dependencies to export.
    # @return [DependencyList] exported dependencies.
    def export(*names)
      @definitions.export(names)
    end

    # Import dependencies which were exported from another container.
    #
    # Used internally by {RailsLoader}.
    #
    # @api private
    # @param definitions [DependencyList] definitions to import.
    # @return [Container] a new container with the imported definitions.
    def import(definitions)
      self.class.new @definitions.import(definitions)
    end

    private

    # @api private
    def define(dependency, resolver)
      self.class.new(@definitions.add(dependency, resolver))
    end
  end
end
