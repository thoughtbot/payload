require 'spec_helper'
require 'payload/undefined_definition'

describe Payload::UndefinedDefinition do
  describe '#==' do
    context 'with the same name' do
      it 'returns true' do
        expect(Payload::UndefinedDefinition.new(:name)).
          to eq(Payload::UndefinedDefinition.new(:name))
      end
    end

    context 'with different names' do
      it 'returns false' do
        expect(Payload::UndefinedDefinition.new(:name)).
          not_to eq(Payload::UndefinedDefinition.new(:other))
      end
    end

    context 'with a different type' do
      it 'returns false' do
        expect(Payload::UndefinedDefinition.new(:name)).
          not_to eq(:other)
      end
    end
  end

  describe '#resolve' do
    it 'raises an undefined dependency error' do
      definition = Payload::UndefinedDefinition.new(:name)

      expect { definition.resolve(double('conatainer')) }.
        to raise_error(Payload::UndefinedDependencyError, /name/)
    end
  end

  describe '#decorate' do
    it 'saves decorators for its replacement' do
      first = double('decorator_one')
      second = double('decorator_two')
      replacement = double('replacement')
      allow(replacement).to receive(:decorate).and_return(replacement)
      definition = Payload::UndefinedDefinition.new(:name)

      defined = definition.
        decorate(first).
        decorate(second).
        set(replacement)

      expect(defined).to eq(replacement)
      expect(replacement).to have_received(:decorate).with(first)
      expect(replacement).to have_received(:decorate).with(second)
    end
  end

  describe '#set' do
    it 'returns the replacement dependency' do
      replacement = double('replacement')
      definition = Payload::UndefinedDefinition.new(:name)

      expect(definition.set(replacement)).
        to eq(replacement)
    end
  end
end
