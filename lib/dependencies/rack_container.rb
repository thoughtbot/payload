module Dependencies
  # Uses a dependency loader to load dependencies and inject them into the Rack
  # environment.
  class RackContainer
    def initialize(app, &loader)
      @app = app
      @loader = loader
    end

    def call(env)
      env[:dependencies] = @loader.call
      @app.call(env)
    end
  end
end
