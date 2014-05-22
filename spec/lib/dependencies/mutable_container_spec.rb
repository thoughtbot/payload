require 'spec_helper'
require 'dependencies/mutable_container'

describe Dependencies::MutableContainer do
  %w(service factory decorate).each do |method_name|
    describe "##{method_name}" do
      it "redefines the container with a #{method_name}" do
        base_container = double('base_container')
        modified_container = double('modified_container')
        base_container
          .stub(method_name)
          .with(:example)
          .and_return(modified_container)
        container = Dependencies::MutableContainer.new(base_container)

        result = container.send(method_name, :example)

        expect(container.build).to eq(modified_container)
        expect(result).to eq(container)
      end
    end
  end

  describe '#respond_to_missing?' do
    context 'for a method defined on its base container' do
      it 'returns true' do
        base_container = double('base_container')
        base_container.stub(:example)
        container = Dependencies::MutableContainer.new(base_container)

        expect(container.method(:example)).to be_present
      end
    end

    context 'for an undefined method' do
      it 'returns false' do
        base_container = double('base_container')
        container = Dependencies::MutableContainer.new(base_container)

        expect { container.method(:unknown) }.to raise_error(NameError)
      end
    end
  end

  describe '#export' do
    it 'adds dependencies to the export list' do
      exports = double('exports')
      immutable_container = double('base_container')
      immutable_container.stub(:service).and_return(immutable_container)
      immutable_container.
        stub(:export).
        with(:one, :two, :three).
        and_return(exports)
      container = Dependencies::MutableContainer.new(immutable_container)

      container.service(:one)
      container.service(:two)
      container.service(:three)
      container.service(:unexported)
      container.export(:one, :two)
      container.export(:three)

      expect(container.exports).to eq(exports)
    end
  end
end
