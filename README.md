# Payload

Payload is a lightweight framework for specifying, injecting, and using
dependencies. It facilitates run-time assembly of dependencies and makes it
plausible to use inversion of control beyond the controller level. It also
attempts to remove boilerplate code for common patterns such as defining
factories and applying decorators.

Overview
--------

The framework makes it easy to define dependencies from application code without
resorting to singletons, constants, or globals. It also won't cause any
class-reloading issues during development.

Define simple dependencies in `config/dependencies.rb` using services:

    service :payment_client do |container|
      PaymentClient.new(ENV['PAYMENT_HOST'])
    end

You can inject dependencies into controllers.

For example, in `app/controllers/payments_controller.rb`:

    class PaymentsController < ApplicationController
      def create
        payment = Payment.new(params[:payment], dependencies[:payment_client])
        receipt = payment.process
        redirect_to receipt
      end
    end

You can easily test this dependency in a controller spec:

    describe PaymentsController do
      describe '#create' do
        it 'processes a payment' do
          payment_params = :product_id => '123', amount: '25'
          client = stub_service(:payment_client)
          payment = double('payment', process: true)
          Payment.stub(:new).with(payment_params, client).and_return(payment)

          post :create, payment_params

          expect(payment).to have_received(:process)
        end
      end
    end

You can further invert control and use factories to hide low-level dependencies
from controllers entirely.

In `config/dependencies.rb`:

    factory :payment do |container|
      Payment.new(container[:attributes], container[:payment_client])
    end

In `app/controllers/payments_controller.rb`:

    class PaymentsController < ApplicationController
      def create
        payment = dependencies[:payment].new(attributes: params[:payment])
        payment.process
        redirect_to payment
      end
    end

You can also stub factories in tests:

    describe PaymentsController do
      describe '#create' do
        it 'processes a payment' do
          payment_params = :product_id => '123', amount: '25'
          payment = stub_factory_instance(:payment, attributes: payment_params)

          post :create, payment_params

          expect(payment).to have_received(:process)
        end
      end
    end

The controller and its tests are now completely ignorant of `payment_client`,
and deal only with the collaborator they need: `payment`.

Setup
-----

Add payload to your Gemfile:

    gem 'payload'

To access dependencies from controllers, include the `Controller` module:

    class ApplicationController < ActionController::Base
      include Payload::Controller
    end

Specifying Dependencies
-----------------------

Edit `config/dependencies.rb` to specify dependencies.

Use the `service` method to define dependencies which can be fully instantiated
during application bootup:

    service :payment_client do |container|
      PaymentClient.new(ENV['PAYMENT_HOST'])
    end

Other dependencies are accessible from the container:

    service :payment_notifier do |container|
      PaymentNotifier.new(container[:mailer])
    end

Use the `factory` method to define dependencies which require dependencies from
the container as well as runtime state which varies per-request:

    factory :payment do |container|
      Payment.new(container[:attributes], container[:payment_client])
    end

The container for factory definitions contains all dependencies defined on the
container as well as dependencies provided when instantiating the factory.

Use the `decorate` method to extend or replace a previously defined dependency:

    decorate :payment do |payment, container|
      NotifyingPayment.new(payment, container[:payment_notifier])
    end

Decorated dependencies have access to other dependencies through the container,
as well as the current definition for that dependency.

Using Dependencies
------------------

The Railtie inserts middleware into the stack which will inject a container into
the Rack environment for each request. This is available as `dependencies` in
controllers and `env[:dependencies]` in the Rack stack.

Use `[]` to access services:

    class PaymentsController < ApplicationController
      def create
        dependencies[:payment_client].charge(params[:amount])
        redirect_to payments_path
      end
    end

Use `new` to instantiate dependencies from factories:

    class PaymentsController < ApplicationController
      def create
        payment = dependencies[:payment].new(attributes: params[:payment])
        payment.process
        redirect_to payment
      end
    end

The `new` method accepts a `Hash`. Each element of the `Hash` will be accessible
from the container in `factory` definitions.

Grouping Dependencies
---------------------

You can enforce simplicity in your dependency graph by grouping dependencies and
explicitly exporting only the dependencies you need to expose to the application
layer.

For example, you can specify payment dependencies in
`config/dependencies/payments.rb`:

    service :payment_client do |container|
      PaymentClient.new(ENV['PAYMENT_HOST'])
    end

    service :payment_notifier do |container|
      PaymentNotifier.new(container[:mailer])
    end

    factory :payment do |container|
      Payment.new(container[:attributes], container[:payment_client])
    end

    decorate :payment do |payment, container|
      NotifyingPayment.new(payment, container[:payment_notifier])
    end

    export :payment

In this example, the final, decorated `:payment` dependency will be available in
controllers, but `:payment_client` and `:payment_notifier` will not.

You can use this approach to hide low-level dependencies behind a facade and
only expose the facade to the application layer.

Testing
-------

To activate testing support, require and mix in the `Testing` module:

    require 'dependencies/testing'

    RSpec.configure do |config|
      config.include Payload::Testing
    end

During integration tests, the fully configured container will be used. During
controller tests, an empty container will be initialized for each test. Tests
can inject the dependencies they need for each interaction.

This module provides two useful methods:

* `stub_service`: Injects a stubbed service into the test container and returns
  it.
* `stub_factory_instance`: Finds or injects a stubbed factory into the test
  container and expects an instance to be created with the given attributes.

Contributing
------------

Please see the [contribution guidelines].

[contribution guidelines]: https://github.com/thoughtbot/payload/blob/master/CONTRIBUTING.md

License
-------

![thoughtbot](http://thoughtbot.com/assets/tm/logo.png)

Payload is Copyright © 2014 Joe Ferris and thoughtbot. It is free software, and
may be redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: https://github.com/thoughtbot/payload/blob/master/LICENSE

Payload is maintained and funded by [thoughtbot, inc](http://thoughtbot.com/).

The names and logos for thoughtbot are trademarks of thoughtbot, inc.
