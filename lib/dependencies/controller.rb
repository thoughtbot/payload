module Dependencies
  # Mixin to provide access to a Container.
  #
  # Include this mixin to access dependencies in controllers. The Container
  # will be injected using RackContainer.
  module Controller
    def dependencies
      request.env[:dependencies]
    end
  end
end
