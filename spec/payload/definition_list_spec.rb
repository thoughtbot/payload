require 'spec_helper'
require 'payload/definition_list'

describe Payload::DefinitionList do
  describe '#add' do
    it 'adds a dependency to be found later' do
      definition = double('definition')
      definition_list = Payload::DefinitionList.new

      defined = definition_list.add(:example, definition)

      expect(defined.find(:example)).to eq(definition)
    end

    it 'does not mutate the list' do
      definition = double('definition')
      definition_list = Payload::DefinitionList.new

      definition_list.add(:example, definition)

      expect { definition_list.find(:example) }.
        to raise_error(Payload::UndefinedDependencyError)
    end
  end

  describe '#export' do
    it 'returns a new list with only the given dependencies' do
      definition_list = Payload::DefinitionList.
        new.
        add(:one, 'first').
        add(:two, 'second').
        add(:three, 'third')
      first_exported = double('exported_first')
      allow(Payload::ExportedDefinition).
        to receive(:new).
        with('first', definition_list).
        and_return(first_exported)
      second_exported = double('exported_second')
      allow(Payload::ExportedDefinition).
        to receive(:new).
        with('second', definition_list).
        and_return(second_exported)

      exported = definition_list.export([:one, :two])

      expect(exported.find(:one)).to eq(first_exported)
      expect(exported.find(:two)).to eq(second_exported)
      expect { exported.find(:three) }.
        to raise_error(Payload::UndefinedDependencyError)
    end
  end

  describe '#import' do
    it 'returns a new list with old dependencies and the given dependencies' do
      left = Payload::DefinitionList.new.add(:one, 'first')
      right = Payload::DefinitionList.new.add(:two, 'second')
      merged = left.import(right)

      expect(merged.find(:one)).to eq('first')
      expect(merged.find(:two)).to eq('second')
    end
  end

  describe '#find' do
    it 'raises for an unknown definition' do
      definition_list = Payload::DefinitionList.new

      expect { definition_list.find(:example) }.
        to raise_error(Payload::UndefinedDependencyError)
    end

    it 'returns an existing definition' do
      definition = double('definition')
      definition_list =
        Payload::DefinitionList.new.add(:example, definition)

      expect(definition_list.find(:example)).to eq(definition)
    end
  end
end
