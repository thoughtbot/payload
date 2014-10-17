require 'payload/definition'
require 'payload/exported_definition'
require 'payload/undefined_definition'

module Payload
  # Immutable list of definitions.
  #
  # Used internally by {Container} to define and look up definitions.
  #
  # @api private
  class DefinitionList
    def initialize(definitions = {})
      @definitions = definitions
    end

    def add(name, resolver)
      value = find(name).set(Definition.new(name, resolver))
      self.class.new(definitions.merge(name => value))
    end

    def find(name)
      definitions.fetch(name) { UndefinedDefinition.new(name) }
    end

    def decorate(name, block)
      decorated = find(name).decorate(block)
      self.class.new(@definitions.merge(name => decorated))
    end

    def export(names)
      exported_definitions = names.inject({}) do |result, name|
        result.merge! name => ExportedDefinition.new(find(name), self)
      end

      self.class.new exported_definitions
    end

    def import(imports)
      self.class.new definitions.merge(imports.definitions)
    end

    protected

    attr_reader :definitions
  end
end
