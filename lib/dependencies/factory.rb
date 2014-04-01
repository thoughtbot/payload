module Dependencies
  # Returned by Container#[] for factory definitions.
  #
  # Used to add definitions from `#new` to the container and then run the
  # factory definition block to obtain an instance.
  class Factory
    def initialize(container, block, decorators)
      @container = container
      @block = block
      @decorators = decorators
    end

    def new(arguments)
      resolved =
        arguments.inject(@container) do |container, (argument, value)|
          container.service(argument) { value }
        end

      base = @block.call(resolved)

      @decorators.decorate(base, resolved)
    end
  end
end
