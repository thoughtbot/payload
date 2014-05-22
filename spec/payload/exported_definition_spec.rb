require 'spec_helper'
require 'payload/exported_definition'
require 'payload/testing'

describe Payload::ExportedDefinition do
  include Payload::Testing

  describe '#resolve' do
    it 'finds definitions from both the source and argument containers' do
      block = lambda do |container|
        "Ran with #{container[:private]} " \
          "and #{container[:container]}"
      end

      private_definition =
        Payload::ServiceDefinition.new(lambda { |config| 'private' })
      private_definitions = Payload::DefinitionList.
        new.
        add(:private, private_definition)
      container = build_container.service(:container) { |config| 'container' }
      definition = Payload::ServiceDefinition.new(block)
      exported_definition =
        Payload::ExportedDefinition.new(definition, private_definitions)

      result = exported_definition.resolve(container)

      expect(result).to eq('Ran with private and container')
    end
  end
end
