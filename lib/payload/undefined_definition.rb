require 'payload/decorator_chain'
require 'payload/undefined_dependency_error'

module Payload
  # Returns from {DefinitionList} when attempting to find an undefined
  # definition.
  #
  # @api private
  class UndefinedDefinition
    def initialize(name, decorators = DecoratorChain.new)
      @name = name
      @decorators = decorators
    end

    def ==(other)
      other.is_a?(UndefinedDefinition) && name == other.name
    end

    def resolve(container)
      raise UndefinedDependencyError, "No definition for dependency: #{name}"
    end

    def decorate(block)
      self.class.new(@name, @decorators.add(block))
    end

    def set(replacement)
      @decorators.inject(replacement) do |definition, decorator|
        definition.decorate(decorator)
      end
    end

    protected

    attr_reader :name
  end
end
