require 'dependencies/exported_definition'
require 'dependencies/undefined_dependency_error'

module Dependencies
  # Immutable list of definitions.
  #
  # Used internally by {Container} to define and look up definitions.
  #
  # @api private
  class DefinitionList
    def initialize(definitions = {})
      @definitions = definitions
    end

    def add(name, definition)
      self.class.new(definitions.merge(name => definition))
    end

    def find(name)
      definitions.fetch(name) do
        raise(UndefinedDependencyError, "No definition for dependency: #{name}")
      end
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
