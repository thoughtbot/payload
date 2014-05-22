require 'payload/decorator_chain'

module Payload
  # Encapsulates logic for resolving service definitions.
  #
  # Used internally by {Container}. Use {Container#service}.
  #
  # @api private
  class ServiceDefinition
    def initialize(block, decorators = DecoratorChain.new)
      @block = block
      @decorators = decorators
    end

    def resolve(container)
      base = @block.call(container)
      @decorators.decorate(base, container)
    end

    def decorate(block)
      self.class.new(@block, @decorators.add(block))
    end
  end
end
