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
    def initialize(resolver, decorators = DecoratorChain.new)
      @resolver = resolver
      @decorators = decorators
    end

    def resolve(container)
      resolver.resolve(container, decorators)
    end

    def decorate(decorator)
      self.class.new resolver, decorators.add(decorator)
    end

    def set(_)
      raise DependencyAlreadyDefinedError
    end

    def ==(other)
      other.is_a?(Definition) &&
        resolver == other.resolver &&
        decorators == other.decorators
    end

    protected

    attr_reader :resolver, :decorators
  end
end
