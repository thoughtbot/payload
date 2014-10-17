require "spec_helper"
require "payload/container"
require "payload/consumer"

describe Payload::Consumer do
  describe "#dependency" do
    context "with a service" do
      it "defines a method to access the service" do
        expected = double("service")
        container = Payload::Container.new.service(:example) { expected }
        result = consume(container) do
          dependency :example

          def result
            example
          end
        end

        expect(result).to eq(expected)
      end
    end

    context "with a factory" do
      it "instantiates the factory" do
        expected = double("factory")
        container = Payload::Container.new.factory(:example) { expected }
        result = consume(container) do
          dependency :example

          def result
            example
          end
        end

        expect(result).to eq(expected)
      end
    end

    context "with an alias" do
      it "defines a method from the aliased dependency" do
        expected = double("dependency")
        container = Payload::Container.new.service(:example) { expected }
        result = consume(container) do
          dependency :aliased, from: :example

          def result
            aliased
          end
        end

        expect(result).to eq(expected)
      end
    end
  end

  describe "#inject" do
    context "using the same name" do
      it "injects the dependency into the container" do
        container = Payload::Container.new.
          service(:from_container) { |resolved| resolved[:injected] }
        result = consume(container) do
          dependency :from_container
          inject :injected

          def result
            from_container
          end

          def injected
            "expected"
          end
        end

        expect(result).to eq("expected")
      end
    end

    context "using an alias" do
      it "injects the dependency using the given alias" do
        container = Payload::Container.new.
          service(:from_container) { |resolved| resolved[:alias] }
        result = consume(container) do
          dependency :from_container
          inject :alias, from: :injected

          def result
            from_container
          end

          def injected
            "expected"
          end
        end

        expect(result).to eq("expected")
      end
    end

    context "with a subclass" do
      it "can define dependencies" do
        superclass = define_consumer {}

        subclass = Class.new(superclass) do
          inject :injected
          dependency :example

          def injected
            "injected"
          end

          def result
            example
          end
        end

        container = Payload::Container.new.
          service(:example) { |resolved| resolved[:injected] }

        result = subclass.new(container).result

        expect(result).to eq("injected")
      end
    end
  end

  def consume(container, &block)
    define_consumer(&block).new(container).result
  end

  def define_consumer(&block)
    Class.new do
      include Payload::Consumer

      attr_reader :dependencies

      def initialize(dependencies)
        @dependencies = dependencies
      end

      class_eval(&block)
    end
  end
end
