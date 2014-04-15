module Dependencies
  # Mutable builder for defining dependencies.
  #
  # Allows defining dependencies without fear of breaking the chain while still
  # encapsulating mutation in one location.
  class MutableContainer
    def initialize(container)
      @container = container
    end

    def method_missing(*args, &block)
      @container = @container.send(*args, &block)
      self
    end

    def build
      @container
    end

    private

    def respond_to_missing?(*args)
      @container.respond_to?(*args)
    end
  end
end
