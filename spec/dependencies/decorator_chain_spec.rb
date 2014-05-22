require 'spec_helper'
require 'dependencies/decorator_chain'

describe Dependencies::DecoratorChain do
  describe '#decorate' do
    it 'applies a series of decorators to a component' do
      chain = Dependencies::DecoratorChain
        .new
        .add(lambda { |base, config| "Decorated #{base} with #{config[:one]}" })
        .add(lambda { |base, config| "#{base} and #{config[:two]}" })

      result = chain.decorate('original', one: 'one', two: 'two')

      expect(result).to eq('Decorated original with one and two')
    end

    it "doesn't mutate" do
      chain = Dependencies::DecoratorChain
        .new
        .add(lambda { |base, config| "Decorated #{base}" })

      chain.add(lambda { |base, config| 'Unreferenced decorator' })

      result = chain.decorate('original', {})

      expect(result).to eq('Decorated original')
    end
  end
end
