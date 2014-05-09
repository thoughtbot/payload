module Dependencies
  # Decorates a base definition such as {ServiceDefinition} to provide access to
  # private dependencies in the {Container} from which the definition was
  # exported.
  #
  # Used internally by {DefinitionList}. Use {Container#export}.
  #
  # @api private
  class ExportedDefinition
    def initialize(definition, private_definitions)
      @definition = definition
      @private_definitions = private_definitions
    end

    def resolve(container)
      @definition.resolve(container.import(@private_definitions))
    end
  end
end
