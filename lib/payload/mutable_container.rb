module Payload
  # Mutable builder for defining dependencies.
  #
  # Allows defining dependencies without fear of breaking the chain while still
  # encapsulating mutation in one location.
  #
  # Decorates a {Container} and delegates definition calls.
  class MutableContainer
    # Used internally by {RailsLoader} to parse dependency definition files.
    #
    # @api private
    def initialize(container)
      @container = container
      @exported_names = []
    end

    # Delegates to {Container} and uses the returned result as the new
    # container.
    # @!method decorate
    # @!method factory
    # @!method service
    def method_missing(*args, &block)
      @container = @container.send(*args, &block)
      self
    end

    # Used internally by {RailsLoader} to return the configured container.
    #
    # @api private
    # @return Container the fully-configured, immutable container.
    def build
      @container
    end

    # Exports dependencies so that they are available in other containers.
    #
    # @param names [Array<Symbol>] dependencies to export.
    def export(*names)
      @exported_names += names
    end

    # Returns dependencies specified by previous {#export} invocations.
    #
    # Used internally by {RailsLoader}.
    #
    # @api private
    def exports
      @container.export(*@exported_names)
    end

    private

    def respond_to_missing?(*args)
      @container.respond_to?(*args)
    end
  end
end
