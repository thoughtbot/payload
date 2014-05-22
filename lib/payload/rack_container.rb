module Payload
  # Uses a dependency loader to load dependencies and inject them into the Rack
  # environment.
  #
  # Accepts a Rack application and a block for loading dependencies as a
  # {Container}. The container will be injected into each Rack request as
  # +:dependencies+ in the Rack environment.
  #
  # Used internally by {Railtie}.
  #
  # @api private
  class RackContainer
    def initialize(app, &loader)
      @app = app
      @loader = loader
    end

    def call(env)
      env[:dependencies] = @loader.call.service(:rack_env) { |container| env }
      @app.call(env)
    end
  end
end
