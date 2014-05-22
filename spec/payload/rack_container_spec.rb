require 'spec_helper'
require 'rack/mock'
require 'payload/rack_container'
require 'payload/testing'

describe Payload::RackContainer do
  include Payload::Testing

  describe '#call' do
    it 'injects its container into the Rack environment' do
      service = double('service')
      dependencies = build_container.
        service(:example) { service }
      app = lambda { |env| [200, {}, [env[:dependencies][:example].inspect]] }
      stack = Payload::RackContainer.new(app) { dependencies }

      response = Rack::MockRequest.new(stack).get('/')

      expect(response.body).to eq(service.inspect)
    end

    it 'injects Rack environment into its container' do
      dependencies = build_container.
        service(:path) { |container| container[:rack_env]['PATH_INFO'] }
      app = lambda { |env| [200, {}, [env[:dependencies][:path]]] }
      stack = Payload::RackContainer.new(app) { dependencies }

      response = Rack::MockRequest.new(stack).get('/some_path')

      expect(response.body).to eq('/some_path')
    end
  end
end
