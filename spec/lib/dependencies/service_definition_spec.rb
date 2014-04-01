require 'spec_helper'
require 'dependencies/service_definition'

describe Dependencies::ServiceDefinition do
  describe '#new' do
    it 'returns a new service using the block' do
      block = lambda { |container| "Ran with #{container[:dependency]}" }
      service = Dependencies::ServiceDefinition.new(block)

      result = service.resolve(dependency: 'expected service')

      expect(result).to eq('Ran with expected service')
    end
  end

  describe '#decorate' do
    it 'returns a new decorated service' do
      block = lambda { |container| "Ran with #{container[:dependency]}" }
      first = lambda do |component, container|
        "decorated #{component} with #{container[:dependency]}"
      end
      second = lambda do |component, container|
        "#{component} and #{container[:other_dependency]}"
      end
      service = Dependencies::ServiceDefinition
        .new(block)
        .decorate(first)
        .decorate(second)

      result = service.resolve(
        dependency: 'service',
        other_dependency: 'other service'
      )

      expect(result)
        .to eq('decorated Ran with service with service and other service')
    end
  end
end
