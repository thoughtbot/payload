module Payload
  # Returned by {Factory#apply}.
  #
  # Used to build up arguments for invoking factory definitions.
  #
  # @see Factory#apply Factory#apply for usage.
  class PartialInstance
    # Used internally by {Factory}.
    #
    # @api private
    def initialize(instance, positional = [], keywords = {})
      @instance = instance
      @positional = positional
      @keywords = keywords
    end

    # @see Factory#apply Factory#apply for usage.
    def apply(*positional, **keywords)
      self.class.new(
        @instance,
        @positional + positional,
        @keywords.merge(keywords)
      )
    end

    # Applies final arguments and invokes the missing method on the target.
    #
    # @see Factory#new Factory#new for usage.
    def method_missing(name, *positional, **keywords, &block)
      apply(*positional, **keywords).evaluate(name, &block)
    end

    protected

    def evaluate(name, &block)
      @instance.public_send(name, *arguments, &block)
    end

    private

    def arguments
      @positional + keyword_arguments
    end

    def keyword_arguments
      if @keywords.empty?
        []
      else
        [@keywords]
      end
    end

    def respond_to_missing?(*arguments)
      @instance.respond_to?(*arguments)
    end
  end
end
