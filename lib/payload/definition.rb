require 'payload/decorator_chain'

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
      @resolver.resolve(container, @decorators)
    end

    def decorate(decorator)
      self.class.new @resolver, @decorators.add(decorator)
    end
  end
end
