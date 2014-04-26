require 'dependencies/undefined_dependency_error'

module Dependencies
  # Base, failure case for definition lookup.
  #
  # Used internally as a last parent in a {DefinitionList} chain.
  #
  # @api private
  class EmptyDefinitionList
    def find(name)
      raise(UndefinedDependencyError, "No definition for dependency: #{name}")
    end
  end
end
