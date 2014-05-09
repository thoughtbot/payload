require 'spec_helper'
require 'dependencies/exported_definition'
require 'dependencies/testing'

describe Dependencies::ExportedDefinition do
  include Dependencies::Testing

  describe '#resolve' do
    it 'finds definitions from both the source and argument containers' do
      block = lambda do |container|
        "Ran with #{container[:private]} " \
          "and #{container[:container]}"
      end

      private_definition =
        Dependencies::ServiceDefinition.new(lambda { |config| 'private' })
      private_definitions = Dependencies::DefinitionList.
        new.
        add(:private, private_definition)
      container = build_container.service(:container) { |config| 'container' }
      definition = Dependencies::ServiceDefinition.new(block)
      exported_definition =
        Dependencies::ExportedDefinition.new(definition, private_definitions)

      result = exported_definition.resolve(container)

      expect(result).to eq('Ran with private and container')
    end
  end
end
