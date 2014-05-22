require 'spec_helper'
require 'payload/service_definition'

describe Payload::ServiceDefinition do
  describe '#resolve' do
    it 'returns a new service using the block' do
      block = lambda { |container| "Ran with #{container[:dependency]}" }
      service = Payload::ServiceDefinition.new(block)

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
      service = Payload::ServiceDefinition
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
