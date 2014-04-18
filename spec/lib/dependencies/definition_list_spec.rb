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
