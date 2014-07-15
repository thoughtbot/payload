module Payload
  # Decorates a base definition such as {ServiceResolver} to provide access to
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
      definition.resolve(container.import(private_definitions))
    end

    def ==(other)
      other.is_a?(ExportedDefinition) &&
        definition == other.definition &&
        private_definitions == other.private_definitions
    end

    protected

    attr_reader :definition, :private_definitions
  end
end
