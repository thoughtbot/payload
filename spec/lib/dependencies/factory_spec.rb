require 'spec_helper'
require 'dependencies/factory'
require 'dependencies/decorator_chain'
require 'dependencies/container'

describe Dependencies::Factory do
  describe '#new' do
    it 'instantiates the dependency' do
      decorator = lambda do |component, config|
        "Decorated #{component.inspect} " \
          "with #{config[:from_container]} " \
          "and #{config[:from_new]}"
      end
      block = lambda do |config|
        "Component with #{config[:from_container]} and #{config[:from_new]}"
      end
      decorators = Dependencies::DecoratorChain.new.add(decorator)
      container = Dependencies::Container.new
        .service(:from_container) { 'From container' }
      factory = Dependencies::Factory.new(container, block, decorators)

      result = factory.new(from_new: 'From new')

      expect(result).to eq(
        'Decorated "Component with From container and From new" ' \
          'with From container and From new'
      )
    end

    it 'instantiates the dependency without arguments' do
      block = lambda do |config|
        "Component with #{config[:from_container]}"
      end
      decorators = Dependencies::DecoratorChain.new
      container = Dependencies::Container.new
        .service(:from_container) { 'From container' }
      factory = Dependencies::Factory.new(container, block, decorators)

      result = factory.new

      expect(result).to eq('Component with From container')
    end
  end
end
