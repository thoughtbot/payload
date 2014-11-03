require 'spec_helper'
require 'payload/definition'

describe Payload::Definition do
  describe '#resolve' do
    it 'provides the container and decorators to its resolver' do
      resolved = double('resolved')
      resolver = double('resolver')
      container = double('container')
      decorators = double('decorators')
      allow(resolver).to receive(:resolve).and_return(resolved)
      definition = Payload::Definition.new(:example, resolver, decorators)

      result = definition.resolve(container)

      expect(result).to eq(resolved)
      expect(resolver).to have_received(:resolve).with(container, decorators)
    end
  end

  describe '#decorate' do
    it 'returns a new decorated service' do
      decorator = double('first_decorator')
      resolver = double('resolver')
      allow(resolver).to receive(:resolve)
      container = double('container')
      decorated = double('decorated')
      decorators = double('decorators')
      allow(decorators).to receive(:add).and_return(decorated)
      allow(Payload::DecoratorChain).to receive(:new).and_return(decorators)
      definition = Payload::Definition.new(:name, resolver)

      definition.
        decorate(decorator).
        resolve(container)

      expect(decorators).to have_received(:add).with(decorator)
      expect(resolver).to have_received(:resolve).with(container, decorated)
    end
  end

  describe '#set' do
    it 'raises an already defined error' do
      service = Payload::Definition.new(:name, double('resolver'))

      expect { service.set(double('replacement')) }.to raise_error(
        Payload::DependencyAlreadyDefinedError,
        "name is already defined"
      )
    end
  end

  describe '#==' do
    it 'is true with the same resolver and decorators' do
      expect(Payload::Definition.new(:name, :resolver).decorate(:decorator)).
        to eq(Payload::Definition.new(:name, :resolver).decorate(:decorator))
    end

    it 'is false with a different name' do
      expect(Payload::Definition.new(:name, :resolver)).
        not_to eq(Payload::Definition.new(:other, :resolver))
    end

    it 'is false with a different resolver' do
      expect(Payload::Definition.new(:name, :resolver).decorate(:decorator)).
        not_to eq(Payload::Definition.new(:name, :other).decorate(:decorator))
    end

    it 'is false with different decorators' do
      expect(Payload::Definition.new(:name, :resolver).decorate(:decorator)).
        not_to eq(Payload::Definition.new(:name, :resolver).decorate(:other))
    end

    it 'is false with a non-definition' do
      expect(Payload::Definition.new(:name, :resolver).decorate(:decorator)).
        not_to eq(:other)
    end
  end
end
