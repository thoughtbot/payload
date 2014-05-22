require 'spec_helper'
require 'tmpdir'
require 'payload/rails_loader'

module Rails
end

describe Payload::RailsLoader do
  describe '.load' do
    it 'returns a proc which returns a Container from config/dependencies.rb' do
      in_rails_root do
        write_config 'dependencies.rb', <<-RUBY
          service(:root) { |container| 'root' }
          service(:using_root) { |container| "using \#{container[:root]}" }
        RUBY

        write_config 'payload/namespace.rb', <<-RUBY
          service(:private) { |container| "private with \#{container[:root]}" }
          service(:exported) { |container| "exported \#{container[:private]}" }
          export :exported
        RUBY

        container = Payload::RailsLoader.load

        expect(container[:root]).to eq('root')
        expect(container[:using_root]).to eq('using root')
        expect(container[:exported]).to eq('exported private with root')
        expect { container[:private] }.
          to raise_error(Payload::UndefinedDependencyError)
      end
    end
  end

  describe '.to_proc' do
    it 'returns a proc which returns a Container from config/dependencies.rb' do
      in_rails_root do
        write_config 'dependencies.rb', <<-RUBY
          service(:example) { |container| 'expected' }
        RUBY

        container = Payload::RailsLoader.to_proc.call

        expect(container[:example]).to eq('expected')
      end
    end
  end

  def in_rails_root(&block)
    Dir.mktmpdir do |path|
      Dir.chdir(path) do
        allow(Rails).to receive(:root).and_return(Pathname.pwd)
        yield
      end
    end
  end

  def write_config(path, contents)
    config_path = File.join('config', path)
    FileUtils.mkdir_p File.dirname(config_path)
    File.open(config_path, 'w') { |file| file.write(contents) }
  end
end
