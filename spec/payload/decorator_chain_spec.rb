require 'spec_helper'
require 'payload/decorator_chain'

describe Payload::DecoratorChain do
  it 'is enumerable' do
    expect(Payload::DecoratorChain.new).to be_a(Enumerable)
  end

  describe '#decorate' do
    it 'applies a series of decorators to a component' do
      chain = Payload::DecoratorChain
        .new
        .add(lambda { |base, config| "Decorated #{base} with #{config[:one]}" })
        .add(lambda { |base, config| "#{base} and #{config[:two]}" })

      result = chain.decorate('original', one: 'one', two: 'two')

      expect(result).to eq('Decorated original with one and two')
    end

    it "doesn't mutate" do
      chain = Payload::DecoratorChain
        .new
        .add(lambda { |base, config| "Decorated #{base}" })

      chain.add(lambda { |base, config| 'Unreferenced decorator' })

      result = chain.decorate('original', {})

      expect(result).to eq('Decorated original')
    end
  end

  describe '#each' do
    it 'yields each decorator' do
      first = double('first')
      second = double('second')
      chain = Payload::DecoratorChain.new.add(first).add(second)
      result = []

      chain.each { |yielded| result << yielded }

      expect(result).to eq([first, second])
    end
  end

  describe '#==' do
    it 'is equal with the same decorators' do
      expect(Payload::DecoratorChain.new.add(:one).add(:two)).
        to eq(Payload::DecoratorChain.new.add(:one).add(:two))
    end

    it 'is unequal with different decorators' do
      expect(Payload::DecoratorChain.new.add(:one).add(:two)).
        not_to eq(Payload::DecoratorChain.new.add(:one).add(:three))
    end

    it 'is unequal with another type' do
      expect(Payload::DecoratorChain.new.add(:one).add(:two)).
        not_to eq(:other)
    end
  end
end
