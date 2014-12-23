require "payload/partial_instance"

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

    # Return a new factory with some of the arguments provided. Remaining
    # arguments can be provided by invoking {Factory#new} on the returned
    # instance. Chaining {Factory#apply} is also possible. This can be useful
    # for returning a factory where some of the dependencies are provided by the
    # container, and the remainder are provided at runtime.
    #
    # @example
    #   container = Payload::Container.new.
    #     factory(:form) { |container, model, attributes|
    #       Form.new(model, attributes)
    #     }.
    #     service(:user_form) { |container| container[:form].apply(User) }
    #   user_form = container[:user_form].new(username: "smith")
    # @param [Array] arguments positional arguments to be passed to the factory
    # @param [Hash] keywords keyword arguments to be passed to the factory
    # @return [PartialInstance] an instance on which you can invoke
    #   {Factory#new}.
    def apply(*arguments, **keywords)
      PartialInstance.new(self).apply(*arguments, **keywords)
    end
  end
end
