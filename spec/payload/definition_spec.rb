require 'spec_helper'
require 'payload/definition'

describe Payload::Definition do
  describe '#resolve' do
    it 'provides the container and decorators to its resolver' do
      resolved = double('resolved')
      resolver = double('resolver')
      container = double('container')
      decorators = double('decorators')
      resolver.stub(:resolve).and_return(resolved)
      definition = Payload::Definition.new(resolver, decorators)

      result = definition.resolve(container)

      expect(result).to eq(resolved)
      expect(resolver).to have_received(:resolve).with(container, decorators)
    end
  end

  describe '#decorate' do
    it 'returns a new decorated service' do
      decorator = double('first_decorator')
      resolver = double('resolver')
      resolver.stub(:resolve)
      container = double('container')
      decorated = double('decorated')
      decorators = double('decorators')
      decorators.stub(:add).and_return(decorated)
      Payload::DecoratorChain.stub(:new).and_return(decorators)
      definition = Payload::Definition.new(resolver)

      definition.
        decorate(decorator).
        resolve(container)

      expect(decorators).to have_received(:add).with(decorator)
      expect(resolver).to have_received(:resolve).with(container, decorated)
    end
  end
end
