module Payload
  # Collects a list of decorators to apply to a component within the context of
  # a container.
  #
  # Used internally by {Container}. Use {Container#decorate}.
  #
  # @api private
  class DecoratorChain
    include Enumerable

    def initialize(decorators = [])
      @decorators = decorators
    end

    def add(decorator)
      self.class.new decorators + [decorator]
    end

    def decorate(base, container)
      decorators.inject(base) do |component, decorator|
        decorator.call(component, container)
      end
    end

    def each(&block)
      decorators.each(&block)
    end

    def ==(other)
      other.is_a?(DecoratorChain) && decorators == other.decorators
    end

    protected

    attr_reader :decorators
  end
end
