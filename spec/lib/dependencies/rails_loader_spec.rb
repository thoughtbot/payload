require 'spec_helper'
require 'dependencies/rails_loader'

describe Dependencies::RailsLoader do
  describe '.load' do
    it 'loads a Container from config/dependencies.rb' do
      stub_config <<-RUBY
        service(:one) { |container| 1 }
        service(:two) { |container| container[:one] * 2 }
      RUBY

      container = Dependencies::RailsLoader.load

      expect(container[:two]).to eq(2)
      expect(container[:one]).to eq(1)
    end
  end

  describe '.to_proc' do
    it 'returns a proc which returns a Container from config/dependencies.rb' do
      stub_config <<-RUBY
        service(:example) { |container| 'expected' }
      RUBY

      container = Dependencies::RailsLoader.to_proc.call

      expect(container[:example]).to eq('expected')
    end
  end

  def stub_config(config)
    Rails.stub(:root).and_return(Pathname.new('/rails/root'))
    IO.
      stub(:read).
      with('/rails/root/config/dependencies.rb').
      and_return(config)
  end
end
