require 'vtasks/utils/docker_shared_context'

# Configura RSpec
::RSpec.configure do |config|
  config.formatter = :documentation
  config.color = true
  config.tty = true
end

# Longer build time out
::Docker.options[:read_timeout] = 7200
