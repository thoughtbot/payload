require "spec_helper"
require "payload/partial_instance"

describe Payload::PartialInstance do
  describe "#method_missing" do
    context "for a method with only positional arguments" do
      it "applies parameters from #initialize and #apply" do
        block = lambda do |first, second, third|
          [first, second, third]
        end

        result = Payload::PartialInstance.
          new(block, ["first"], {}).
          apply("second").
          call("third")

        expect(result).to eq(%w(first second third))
      end
    end

    context "for a method with keyword arguments" do
      it "combines keyword arguments" do
        block = lambda do |first, second, third, a: nil, b: nil, c: nil|
          [first, second, third, a, b, c]
        end

        result = Payload::PartialInstance.
          new(block, ["first"], { a: "a" }).
          apply("second", b: "b").
          call("third", c: "c")

        expect(result).to eq(%w(first second third a b c))
      end
    end
  end

  describe "#respond_to_missing?" do
    context "for a method defined on its instance" do
      it "returns true" do
        instance = double("instance")
        allow(instance).to receive(:example)
        partial = Payload::PartialInstance.new(instance)

        expect(partial.method(:example)).not_to be_nil
      end
    end

    context "for an undefined method" do
      it "returns false" do
        instance = double("instance")
        partial = Payload::PartialInstance.new(instance)

        expect { partial.method(:unknown) }.to raise_error(NameError)
      end
    end
  end
end
