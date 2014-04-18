require 'spec_helper'
require 'dependencies/container'
require 'dependencies/testing'

describe Dependencies::Container do
  include Dependencies::Testing

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
        .to raise_error(Dependencies::UndefinedDependencyError)
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

    it 'raises an exception for an unknown dependency' do
      container = build_container

      expect { container.decorate(:anything) }
        .to raise_error(Dependencies::UndefinedDependencyError)
    end
  end

  describe '#[]' do
    context 'with an undefined dependency' do
      it 'raises an undefined dependency error' do
        container = build_container

        expect { container[:undefined] }.to raise_error(
          Dependencies::UndefinedDependencyError,
          'No definition for dependency: undefined'
        )
      end
    end
  end
end
