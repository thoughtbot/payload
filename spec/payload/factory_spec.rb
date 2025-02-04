require "spec_helper"
require "payload/factory"
require "payload/decorator_chain"
require "payload/testing"

describe Payload::Factory do
  include Payload::Testing

  describe "#new" do
    it "instantiates the dependency" do
      decorator = lambda do |component, config, from_new|
        "Decorated #{component.inspect}" \
          " with #{config[:from_container]} and #{from_new}"
      end
      block = lambda do |config, from_new|
        "Component with #{config[:from_container]} and #{from_new}"
      end
      decorators = Payload::DecoratorChain.new.add(decorator)
      container = build_container.service(:from_container) { "From container" }
      factory = Payload::Factory.new(container, block, decorators)

      result = factory.new("From new")

      expect(result).to eq(
        'Decorated "Component with From container and From new" ' \
          "with From container and From new"
      )
    end

    it "instantiates the dependency without arguments" do
      block = lambda do |config|
        "Component with #{config[:from_container]}"
      end
      decorators = Payload::DecoratorChain.new
      container = build_container.service(:from_container) { "From container" }
      factory = Payload::Factory.new(container, block, decorators)

      result = factory.new

      expect(result).to eq("Component with From container")
    end
  end

  describe "#apply" do
    it "applies arguments" do
      container = build_container
      block = lambda { |config, applied, local| "Got #{applied} and #{local}" }
      decorators = Payload::DecoratorChain.new
      factory = Payload::Factory.new(container, block, decorators)

      result = factory.apply("applied").new("local")

      expect(result).to eq("Got applied and local")
    end
  end
end
