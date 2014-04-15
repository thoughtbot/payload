require 'spec_helper'
require 'dependencies/rails_loader'

describe Dependencies::RailsLoader do
  describe '#to_proc' do
    it 'returns a proc which returns a Container from config/dependencies.rb' do
      config = <<-RUBY
        service(:one) { |container| 1 }
        service(:two) { |container| container[:one] * 2 }
      RUBY
      Rails.stub(:root).and_return(Pathname.new('/rails/root'))
      IO
      .stub(:read)
      .with('/rails/root/config/dependencies.rb')
      .and_return(config)
      proc = Dependencies::RailsLoader.new.to_proc

      container = proc.call

      expect(container[:two]).to eq(2)
      expect(container[:one]).to eq(1)
    end
  end
end
