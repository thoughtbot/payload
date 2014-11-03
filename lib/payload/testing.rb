require 'payload/definition_list'
require 'payload/container'

module Payload
  # Helper methods for stubbing and injecting dependencies into unit tests.
  #
  # These methods are intended for rspec controller tests and require
  # rspec-mocks to work as expected. During capybara tests, all dependencies
  # are available as defined in +config/dependencies.rb+.
  module Testing
    # Builds an empty {Container} in the fake Rack environment.
    #
    # @api private
    def setup_controller_request_and_response
      super
      @request.env[:dependencies] = build_container
    end

    # Finds or injects a stubbed factory into the test {Container} and stubs an
    # instance to be created with the given attributes.
    #
    # @param dependency [Symbol] the name of the factory to stub.
    # @param attributes [Hash] the expected attributes to build the instance.
    # @return [RSpec::Mocks::TestDouble] the result of the factory, which can
    #   then have additional stubs or expectations applied to it.
    def stub_factory_instance(dependency, attributes)
      factory = stub_factory(dependency)
      double(dependency.to_s).tap do |double|
        allow(factory).to receive(:new).with(attributes).and_return(double)
      end
    end

    # Injects a stubbed factory into the test {Container} and returns it.
    #
    # @param dependency [Symbol] the name of the factory to stub.
    # @return [RSpec::Mocks::TestDouble] the stubbed factory, which can have
    #   stubs for `new` applied to it.
    def stub_factory(dependency)
      dependencies[dependency]
    rescue Payload::UndefinedDependencyError
      double("#{dependency} factory").tap do |factory|
        modify_dependencies do |dependencies|
          dependencies.service(dependency) do |config|
            factory
          end
        end
      end
    end

    # Injects a stubbed service into the test {Container} and returns it.
    #
    # @param dependency [Symbol] the name of the service to stub.
    # @return [RSpec::Mocks::TestDouble] the stubbed service, which can then
    #   have additional stubs or expectations applied to it.
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
    # @yield [Container] the container to be modified. The block should return
    #   the new container.
    def modify_dependencies
      @request.env[:dependencies] = yield(dependencies)
    end

    # @return the current {Container} which will be injected into the test Rack
    #   session.
    def dependencies
      @request.env[:dependencies]
    end

    # @api private
    def build_container
      Container.new
    end
  end
end
