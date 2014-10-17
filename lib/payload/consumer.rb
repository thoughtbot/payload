module Payload
  # Mixin for using dependencies from a container, mixed with dependencies from
  # local state.
  #
  # To use this mixin, first define a dependencies method which returns a
  # {Container}. Then, use {dependency} and {inject} to define your
  # dependencies.
  #
  # You can use these methods in a Rails application by mixing {Controller} into
  # your controller (or into ApplicationController).
  module Consumer
    # @api private
    def self.included(base)
      super

      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      # Defines a method for using a dependency from the container.
      #
      # @param name [Symbol] the name of the method to define.
      # @param from [Symbol] the name of the dependency to use (optional).
      def dependency(name, from: name)
        define_method(name) { resolved_container.new(from) }
        private(name)
      end

      # Injects a method from this class into the container for use by other
      # dependencies.
      #
      # @param name [Symbol] the name of the dependency to define.
      # @param from [Symbol] the name of the method to inject (optional).
      def inject(name, from: name)
        injected_dependencies[name] = from
      end

      # @api private
      def injected_dependencies
        @injected_dependencies ||= {}
      end
    end

    module InstanceMethods
      private

      def resolved_container
        @resolved_container ||=
          self.class.injected_dependencies.
            inject(dependencies) do |container, (name, from)|
              container.service(name) { __send__(from) }
            end
      end
    end
  end
end
