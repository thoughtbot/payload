module Payload
  # Returned by {Container#[]} for {Container#factory} definitions.
  #
  # Used to add definitions from {#new} to the {Container} and then run the
  # factory definition block to obtain an instance.
  #
  # @see Container#factory Container#factory for defining and using factories.
  class Factory
    # Used internally by {FactoryResolver}.
    #
    # @api private
    def initialize(container, block, decorators)
      @container = container
      @block = block
      @decorators = decorators
    end

    # @param [Array] arguments additional arguments to pass to the factory
    #   definition block.
    # @return the instance defined by the factory definition block.
    # @see Container#factory Container#factory for defining and using factories.
    def new(*arguments)
      base = @block.call(@container, *arguments)
      @decorators.decorate(base, @container, *arguments)
    end
  end
end
