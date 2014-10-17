require 'spec_helper'
require 'payload/definition_list'

describe Payload::DefinitionList do
  describe '#add' do
    it 'adds a dependency to be found later' do
      resolver = double('resolver')
      definition = Payload::Definition.new(:example, resolver)
      definition_list = Payload::DefinitionList.new

      defined = definition_list.add(:example, resolver)

      expect(defined.find(:example)).to eq(definition)
    end

    it 'does not replace an existing definition' do
      definition_list = Payload::DefinitionList.new

      defined = definition_list.add(:example, :original)

      expect { defined.add(:example, :replacement) }.
        to raise_error(Payload::DependencyAlreadyDefinedError)
    end

    it 'does not mutate the list' do
      resolver = double('resolver')
      definition_list = Payload::DefinitionList.new

      definition_list.add(:example, resolver)

      expect(definition_list.find(:example)).
        to eq(Payload::UndefinedDefinition.new(:example))
    end
  end

  describe '#decorate' do
    it 'replaces a dependency with a decorated version' do
      resolver = double('resolver')
      decorator = double('decorator')
      decorated =
        Payload::Definition.new(:example, resolver).decorate(decorator)
      definition_list = Payload::DefinitionList.new

      defined = definition_list.
        add(:example, resolver).
        decorate(:example, decorator)

      expect(defined.find(:example)).to eq(decorated)
    end

    it 'decorates an undefined dependency' do
      resolver = double('resolver')
      decorator = double('decorator')
      decorated =
        Payload::Definition.new(:example, resolver).decorate(decorator)
      definition_list = Payload::DefinitionList.new

      defined = definition_list.
        decorate(:example, decorator).
        add(:example, resolver)

      expect(defined.find(:example)).to eq(decorated)
    end

    it 'does not mutate the list' do
      resolver = double('resolver')
      decorator = double('decorator')
      definition = Payload::Definition.new(:example, resolver)
      definition_list = Payload::DefinitionList.new

      defined = definition_list.add(:example, resolver)

      defined.decorate(:example, decorator)

      expect(defined.find(:example)).to eq(definition)
    end
  end

  describe '#export' do
    it 'returns a new list with only the given dependencies' do
      definition_list = Payload::DefinitionList.
        new.
        add(:one, 'first').
        add(:two, 'second').
        add(:three, 'third')

      exported = definition_list.export([:one, :two])

      first = Payload::ExportedDefinition.new(
        Payload::Definition.new(:one, 'first'),
        definition_list
      )
      second = Payload::ExportedDefinition.new(
        Payload::Definition.new(:two, 'second'),
        definition_list
      )
      third = Payload::UndefinedDefinition.new(:three)
      expect(exported.find(:one)).to eq(first)
      expect(exported.find(:two)).to eq(second)
      expect(exported.find(:three)).to eq(third)
    end
  end

  describe '#import' do
    it 'returns a new list with old dependencies and the given dependencies' do
      left = Payload::DefinitionList.new.add(:one, 'first')
      right = Payload::DefinitionList.new.add(:two, 'second')
      merged = left.import(right)

      expect(merged.find(:one)).to eq(Payload::Definition.new(:one, 'first'))
      expect(merged.find(:two)).to eq(Payload::Definition.new(:two, 'second'))
    end
  end

  describe '#find' do
    it 'returns an unknown definition' do
      definition_list = Payload::DefinitionList.new

      expect(definition_list.find(:example)).
        to eq(Payload::UndefinedDefinition.new(:example))
    end

    it 'returns an existing definition' do
      resolver = double('resolver')
      definition = Payload::Definition.new(:example, resolver)
      definition_list =
        Payload::DefinitionList.new.add(:example, resolver)

      expect(definition_list.find(:example)).to eq(definition)
    end
  end
end
