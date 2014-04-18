module Dependencies
  # Immutable, chainable list of definitions.
  #
  # Used internally by Container to define and look up definitions.
  class DefinitionList
    def initialize(parent, definitions = {})
      @parent = parent
      @definitions = definitions
    end

    def add(name, definition)
      self.class.new(@parent, @definitions.merge(name => definition))
    end

    def find(name)
      @definitions.fetch(name) { @parent.find(name) }
    end
  end
end
