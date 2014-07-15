require 'payload/factory'

module Payload
  # Encapsulates logic for resolving factory definitions.
  #
  # Used internally by {Container}. Use {Container#factory}.
  #
  # @api private
  class FactoryResolver
    def initialize(block)
      @block = block
    end

    def resolve(container, decorators)
      Factory.new(container, @block, decorators)
    end
  end
end
