require 'spec_helper'
require 'dependencies/empty_definition_list'

describe Dependencies::EmptyDefinitionList do
  describe '#find' do
    it 'raises an error' do
      definition_list = Dependencies::EmptyDefinitionList.new

      expect { definition_list.find(:example) }.
        to raise_error(Dependencies::UndefinedDependencyError)
    end
  end
end
