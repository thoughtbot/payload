require 'spec_helper'
require 'dependencies/factory_definition'
require 'dependencies/testing'

describe Dependencies::FactoryDefinition do
  include Dependencies::Testing

  describe '#resolve' do
    it 'returns an object that responds to new' do
      block = lambda do |config|
        "#{config[:from_new]} and #{config[:from_container]}"
      end
      container = build_container
        .service(:from_container) { 'From container' }
      definition = Dependencies::FactoryDefinition.new(block)

      result = definition.resolve(container).new(from_new: 'From new')

      expect(result).to eq('From new and From container')
    end
  end

  describe '#decorate' do
    it 'returns a decorated object' do
      block = lambda do |config|
        "#{config[:from_new]} and #{config[:from_container]}"
      end
      first = lambda do |component, config|
        "Decorated #{component.inspect} with #{config[:from_new]}"
      end
      second = lambda do |component, config|
        "#{component} and #{config[:other]}"
      end
      container = build_container
        .service(:from_container) { 'From container' }
        .service(:other) { 'Other' }
      definition = Dependencies::FactoryDefinition
        .new(block)
        .decorate(first)
        .decorate(second)

      result = definition.resolve(container).new(from_new: 'From new')

      expect(result).to eq(
        'Decorated "From new and From container" with From new and Other'
      )
    end
  end
end
