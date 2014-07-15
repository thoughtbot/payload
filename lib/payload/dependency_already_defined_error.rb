module Payload
  # Raised when attempting to define a dependency which is already defined.
  class DependencyAlreadyDefinedError < StandardError
  end
end
