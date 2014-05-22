require 'payload/decorator_chain'
require 'payload/factory'

module Payload
  # Encapsulates logic for resolving factory definitions.
  #
  # Used internally by {Container}. Use {Container#factory}.
  #
  # @api private
  class FactoryDefinition
    def initialize(block, decorators = DecoratorChain.new)
      @block = block
      @decorators = decorators
    end

    def resolve(container)
      Factory.new(container, @block, @decorators)
    end

    def decorate(block)
      self.class.new(@block, @decorators.add(block))
    end
  end
end
