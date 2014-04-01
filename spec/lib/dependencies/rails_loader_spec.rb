require 'spec_helper'
require 'dependencies/rails_loader'

describe Dependencies::RailsLoader do
  describe '#to_proc' do
    it 'returns a proc which returns a Container from config/dependencies.rb' do
      config = "service(:example) { |config| 'expected value' }"
      Rails.stub(:root).and_return(Pathname.new('/rails/root'))
      IO
      .stub(:read)
      .with('/rails/root/config/dependencies.rb')
      .and_return(config)
      proc = Dependencies::RailsLoader.new.to_proc

      container = proc.call

      expect(container[:example]).to eq('expected value')
    end
  end
end
