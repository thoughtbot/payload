module Dependencies
  # Collects a list of decorators to apply to a component within the context of
  # a container.
  #
  # Used internally by {Container}. Use {Container#decorate}.
  #
  # @api private
  class DecoratorChain
    def initialize(decorators = [])
      @decorators = decorators
    end

    def add(decorator)
      self.class.new @decorators + [decorator]
    end

    def decorate(base, container)
      @decorators.inject(base) do |component, decorator|
        decorator.call(component, container)
      end
    end
  end
end
