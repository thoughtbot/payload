module Payload
  # Encapsulates logic for resolving service definitions.
  #
  # Used internally by {Container}. Use {Container#service}.
  #
  # @api private
  class ServiceResolver
    def initialize(block)
      @block = block
    end

    def resolve(container, decorators)
      base = @block.call(container)
      decorators.decorate(base, container)
    end
  end
end
