require 'spec_helper'
require 'payload/service_resolver'

describe Payload::ServiceResolver do
  shared_examples "service resolver" do |method_name:|
    describe "##{method_name}" do
      it "returns a new service using the block and decorators" do
        dependency = double("dependency")
        container = { dependency: dependency }
        decorated = double("decorated")
        decorators = double("decorators")
        allow(decorators).
          to receive(:decorate).
          with(dependency, container).
          and_return(decorated)
        block = lambda { |yielded| yielded[:dependency] }
        service = Payload::ServiceResolver.new(block)

        result = service.__send__(method_name, container, decorators)

        expect(result).to eq(decorated)
      end
    end
  end

  describe "#resolve" do
    it_behaves_like "service resolver", method_name: :resolve
  end

  describe "#new" do
    it_behaves_like "service resolver", method_name: :new
  end
end
