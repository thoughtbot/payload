require 'spec_helper'
require 'dependencies/definition_list'

describe Dependencies::DefinitionList do
  describe '#add' do
    it 'adds a dependency to be found later' do
      definition = double('definition')
      definition_list = Dependencies::DefinitionList.new(nil_list)

      defined = definition_list.add(:example, definition)

      expect(defined.find(:example)).to eq(definition)
    end

    it 'does not mutate the list' do
      definition = double('definition')
      definition_list = Dependencies::DefinitionList.new(nil_list)

      definition_list.add(:example, definition)

      expect(definition_list.find(:example)).to be_nil
    end
  end

  describe '#export' do
    it 'returns a new list with only the given dependencies' do
      parent = double('parent', find: 'undefined')
      definition_list = Dependencies::DefinitionList.
        new(parent).
        add(:one, 'first').
        add(:two, 'second').
        add(:three, 'third')
      first_exported = double('exported_first')
      Dependencies::ExportedDefinition.
        stub(:new).
        with('first', definition_list).
        and_return(first_exported)
      second_exported = double('exported_second')
      Dependencies::ExportedDefinition.
        stub(:new).
        with('second', definition_list).
        and_return(second_exported)

      exported = definition_list.export([:one, :two])

      expect(exported.find(:one)).to eq(first_exported)
      expect(exported.find(:two)).to eq(second_exported)
      expect(exported.find(:three)).to eq('undefined')
    end
  end

  describe '#import' do
    it 'returns a new list with old dependencies and the given dependencies' do
      left = Dependencies::DefinitionList.new(nil_list).add(:one, 'first')
      right = Dependencies::DefinitionList.new(nil_list).add(:two, 'second')
      merged = left.import(right)

      expect(merged.find(:one)).to eq('first')
      expect(merged.find(:two)).to eq('second')
    end
  end

  describe '#find' do
    it 'finds a definition from its parent' do
      definition = double('definition')
      parent = double('parent')
      parent.stub(:find).with(:example).and_return(definition)
      definition_list = Dependencies::DefinitionList.new(parent)

      expect(definition_list.find(:example)).to eq(definition)
    end

    it 'prefers its own definitions' do
      definition = double('definition')
      parent_definition = double('parent_definition')
      parent = double('parent')
      parent.stub(:find).with(:example).and_return(parent_definition)
      definition_list = Dependencies::DefinitionList.
        new(parent).
        add(:example, definition)

      expect(definition_list.find(:example)).to eq(definition)
    end
  end

  def nil_list
    double('nil_list', find: nil)
  end
end
