require 'spec_helper'
require 'dependencies/rack_container'

describe Dependencies::RackContainer do
  describe '#call' do
    it 'injects its container into the Rack environment' do
      dependencies = double('dependencies')
      app = lambda { |env| [200, {}, [env[:dependencies].inspect]] }
      stack = Dependencies::RackContainer.new(app) { dependencies }

      response = Rack::MockRequest.new(stack).get('/')

      expect(response.body).to eq(dependencies.inspect)
    end
  end
end
