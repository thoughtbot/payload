require 'spec_helper'
require 'payload/container'
require 'payload/testing'

describe Payload::Container do
  include Payload::Testing

  describe '#factory' do
    it 'returns an object that responds to new' do
      container = build_container
        .service(:from_container) { |config| 'From container' }
        .factory(:example) do |config|
          "#{config[:from_new]} and #{config[:from_container]}"
        end

      result = container[:example].new(from_new: 'From new')

      expect(result).to eq('From new and From container')
    end
  end

  describe '#service' do
    it 'returns a container with the given dependency defined' do
      container = build_container
        .service(:example) { |config| 'expected result' }

      expect(container[:example]).to eq('expected result')
    end

    it "doesn't mutate the container" do
      original = build_container
      original.service(:example) { |config| 'expected result' }

      expect { original[:example] }
        .to raise_error(Payload::UndefinedDependencyError)
    end

    it 'provides access to other dependencies' do
      container = build_container
        .service(:example) { |config| "got #{config[:dependency].inspect}" }
        .service(:dependency) { |config| 'expected result' }

      expect(container[:example]).to eq('got "expected result"')
    end
  end

  describe '#decorate' do
    it 'returns a container with the given dependency decorated' do
      container = build_container
        .service(:example) { |config| 'expected component' }
        .decorate(:example) do |component, config|
          "decorated #{component.inspect} with #{config[:param].inspect}"
        end
        .decorate(:example) { |component, config| "redecorated #{component}" }
        .service(:param) { |config| 'expected param' }

      expect(container[:example]).to eq(
        'redecorated decorated "expected component" with "expected param"'
      )
    end

    it "doesn't mutate the container" do
      original = build_container
        .service(:example) { |config| 'expected component' }
      original
        .decorate(:example) { |component, config| "decorated #{component}" }

      expect(original[:example]).to eq('expected component')
    end

    it 'decorates a dependency which is defined later' do
      container = build_container.
        decorate(:example) { |component, _| "decorated #{component}" }.
        service(:example) { |_| 'expected component' }

      expect(container[:example]).to eq('decorated expected component')
    end

    it 'raises an exception for an unknown dependency' do
      container = build_container

      expect { container.decorate(:undefined)[:undefined] }
        .to raise_error(Payload::UndefinedDependencyError)
    end
  end

  describe '#export' do
    it 'allows access to exported definitions' do
      exports = build_container.
        service(:example) { |config| 'expected component' }.
        export(:example)
      container = build_container.import(exports)

      expect(container[:example]).to eq('expected component')
    end

    it 'does not allow access to private definitions' do
      exports = build_container.
        service(:exported) { |config| 'exported' }.
        service(:private) { |config| 'private' }.
        export(:exported)
      container = build_container.import(exports)

      expect { container[:private] }.
        to raise_error(Payload::UndefinedDependencyError)
    end

    it 'allows exported definitions to reference private definitions' do
      exports = build_container.
        service(:exported) { |config| "got #{config[:private].inspect}" }.
        service(:private) { |config| 'private' }.
        export(:exported)
      container = build_container.import(exports)

      expect(container[:exported]).to eq('got "private"')
    end

    it 'exposes local definitions to private definitions' do
      exports = build_container.
        service(:exported) { |config| "got #{config[:local].inspect}" }.
        export(:exported)
      container = build_container.
        service(:local) { |config| 'local' }.
        import(exports)

      expect(container[:exported]).to eq('got "local"')
    end
  end

  describe '#import' do
    it 'returns a new container with the given definitions' do
      first_export =
        Payload::ServiceResolver.new(lambda { |config| 'one' })
      second_export =
        Payload::ServiceResolver.new(lambda { |config| 'two' })
      definitions = Payload::DefinitionList.
        new.
        add(:one, first_export).
        add(:two, second_export)
      container = build_container.
        service(:original) { |config| 'original' }.
        import(definitions)

      expect(container[:original]).to eq('original')
      expect(container[:one]).to eq('one')
      expect(container[:two]).to eq('two')
    end
  end

  describe '#[]' do
    context 'with an undefined dependency' do
      it 'raises an undefined dependency error' do
        container = build_container

        expect { container[:undefined] }.to raise_error(
          Payload::UndefinedDependencyError,
          'No definition for dependency: undefined'
        )
      end
    end
  end
end
