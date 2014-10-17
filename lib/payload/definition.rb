require 'payload/decorator_chain'
require 'payload/dependency_already_defined_error'

module Payload
  # Definition for a dependency which can be resolved and decorated.
  #
  # Used internally by {DefinitionList}. Use {Container#service} or
  # {Container#fatory}.
  #
  # @api private
  class Definition
    def initialize(name, resolver, decorators = DecoratorChain.new)
      @name = name
      @resolver = resolver
      @decorators = decorators
    end

    def resolve(container)
      resolver.resolve(container, decorators)
    end

    def decorate(decorator)
      self.class.new name, resolver, decorators.add(decorator)
    end

    def set(_)
      raise DependencyAlreadyDefinedError, "#{name} is already defined"
    end

    def ==(other)
      other.is_a?(Definition) &&
        name == other.name &&
        resolver == other.resolver &&
        decorators == other.decorators
    end

    protected

    attr_reader :name, :resolver, :decorators
  end
end
