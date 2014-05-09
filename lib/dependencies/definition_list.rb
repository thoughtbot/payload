require 'dependencies/exported_definition'

module Dependencies
  # Immutable, chainable list of definitions.
  #
  # Used internally by {Container} to define and look up definitions.
  #
  # @api private
  class DefinitionList
    def initialize(parent, definitions = {})
      @parent = parent
      @definitions = definitions
    end

    def add(name, definition)
      self.class.new(@parent, definitions.merge(name => definition))
    end

    def find(name)
      definitions.fetch(name) { @parent.find(name) }
    end

    def export(names)
      exported_definitions = names.inject({}) do |result, name|
        result.merge! name => ExportedDefinition.new(find(name), self)
      end

      self.class.new @parent, exported_definitions
    end

    def import(imports)
      self.class.new @parent, definitions.merge(imports.definitions)
    end

    protected

    attr_reader :definitions
  end
end
