module Payload
  # Mixin to provide access to a {Container}.
  #
  # Include this mixin to access dependencies in controllers. The {Container}
  # will be injected using {RackContainer}.
  module Controller
    # @return [Container] dependencies injected from {RackContainer}.
    def dependencies
      request.env[:dependencies]
    end
  end
end
