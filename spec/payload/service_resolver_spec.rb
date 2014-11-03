require 'spec_helper'
require 'payload/service_resolver'

describe Payload::ServiceResolver do
  describe '#resolve' do
    it 'returns a new service using the block and decorators' do
      dependency = double('dependency')
      container = { dependency: dependency }
      decorated = double('decorated')
      decorators = double('decorators')
      allow(decorators).
        to receive(:decorate).
        with(dependency, container).
        and_return(decorated)
      block = lambda { |yielded| yielded[:dependency] }
      service = Payload::ServiceResolver.new(block)

      result = service.resolve(container, decorators)

      expect(result).to eq(decorated)
    end
  end
end
