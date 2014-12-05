require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end
