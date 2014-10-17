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
        Payload::ServiceResolver.new(lambda { |config| 'private' })
      private_definitions = Payload::DefinitionList.
        new.
        add(:private, private_definition)
      container = build_container.service(:container) { |config| 'container' }
      definition =
        Payload::Definition.new(:name, Payload::ServiceResolver.new(block))
      exported_definition =
        Payload::ExportedDefinition.new(definition, private_definitions)

      result = exported_definition.resolve(container)

      expect(result).to eq('Ran with private and container')
    end
  end

  describe '#==' do
    it 'is true with the same definitions' do
      expect(Payload::ExportedDefinition.new(:one, [:two, :three])).
        to eq(Payload::ExportedDefinition.new(:one, [:two, :three]))
    end

    it 'is false with a different public definition' do
      expect(Payload::ExportedDefinition.new(:one, [:two, :three])).
        not_to eq(Payload::ExportedDefinition.new(:other, [:two, :three]))
    end

    it 'is false with different private definitions' do
      expect(Payload::ExportedDefinition.new(:one, [:two, :three])).
        not_to eq(Payload::ExportedDefinition.new(:one, [:two, :other]))
    end

    it 'is false with another type' do
      expect(Payload::ExportedDefinition.new(:one, [:two, :three])).
        not_to eq(:other)
    end
  end
end
