require 'dependencies/empty_definition_list'
require 'dependencies/definition_list'
require 'dependencies/container'

module Dependencies
  module Testing
    def setup_controller_request_and_response
      super
      @request.env[:dependencies] = build_container
    end

    # Stubs a factory which will be instantiated with the given attributes.
    #
    # Returns the result of the factory, which can then have additional stubs
    # or expectations applied to it.
    def stub_factory_instance(dependency, attributes)
      factory = stub_factory(dependency)
      double(dependency.to_s).tap do |double|
        factory.stub(:new).with(attributes).and_return(double)
      end
    end

    # Stubs a factory.
    #
    # Returns the stubbed factory, which can have stubs for `new` applied to it.
    def stub_factory(dependency)
      dependencies[dependency]
    rescue Dependencies::UndefinedDependencyError
      double("#{dependency} factory").tap do |factory|
        modify_dependencies do |dependencies|
          dependencies.service(dependency) do |config|
            factory
          end
        end
      end
    end

    # Stubs a service.
    #
    # Returns the stubbed service, which can then have additional stubs or
    # expectations applied to it.
    def stub_service(dependency)
      double(dependency.to_s).tap do |double|
        modify_dependencies do |dependencies|
          dependencies.service(dependency) do |config|
            double
          end
        end
      end
    end

    # Convenience for injecting a modified container into the test rack session.
    #
    # Yields the container to be modified. The block should return the new
    # container.
    def modify_dependencies
      @request.env[:dependencies] = yield(dependencies)
    end

    # Returns the current container which will be injected into the test rack
    # session.
    def dependencies
      @request.env[:dependencies]
    end

    def build_container
      Container.new(DefinitionList.new(EmptyDefinitionList.new))
    end
  end
end
