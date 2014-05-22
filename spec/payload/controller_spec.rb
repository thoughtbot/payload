require 'spec_helper'
require 'payload/controller'

describe Payload::Controller do
  describe '#dependencies' do
    it 'looks for dependencies from the Rack environment' do
      dependency = double('dependency')
      container = { lookup: dependency }
      env = { dependencies: container }
      request = double('request', env: env)
      controller_class = Class.new do
        include Payload::Controller

        def initialize(request)
          @request = request
        end

        def lookup
          dependencies[:lookup]
        end

        private

        attr_reader :request
      end

      result = controller_class.new(request).lookup

      expect(result).to eq(dependency)
    end
  end
end
