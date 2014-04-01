require 'dependencies/decorator_chain'
require 'dependencies/factory'

module Dependencies
  # Encapsulates logic for resolving factory definitions.
  #
  # Used internally by Container. Use Container#factory.
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
