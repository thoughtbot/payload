module Payload
  # Mixin to provide access to a {Container}.
  #
  # Include this mixin to access dependencies in controllers. The {Container}
  # will be injected using {RackContainer}. Use methods from {Consumer} to
  # inject dependencies and decide which to use.
  #
  # @example
  #   class PostsController < ApplicationController
  #     inject :author, from: :current_user
  #     dependency :post_factory
  #
  #     def create
  #       post_factory.new.save
  #     end
  #   end
  module Controller
    include Consumer

    # @return [Container] dependencies injected from {RackContainer}.
    def dependencies
      request.env[:dependencies]
    end
  end
end
