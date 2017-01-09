require 'serverspec'
require 'docker'

# Configura RSpec
RSpec.configure do |config|
  config.formatter = :documentation
  config.color = true
  config.tty = true
end

# Travis builds can take time
Docker.options[:read_timeout] = 7200

# Docker image context
shared_context 'shared docker image' do
  before(:all) do
    @image = Docker::Image.build_from_dir(DOCKER_IMAGE_DIRECTORY)
    set :backend, :docker
  end
end

# Clean-up
shared_context 'clean-up' do
  after(:all) do
    @container.kill
    @container.delete(force: true)
  end
end

# Docker container context
shared_context 'with a docker container' do
  include_context 'shared docker image'

  before(:all) do
    @container = Docker::Container.create('Image' => @image.id)
    @container.start

    set :docker_container, @container.id
  end

  include_context 'clean-up'
end

# Docker always running container
# Overwrite the entrypoint so that we can run the tests
shared_context 'with a docker container (override entrypoint)' do
  include_context 'shared docker image'

  before(:all) do
    @container = Docker::Container.create(
      'Image' => @image.id,
      'Entrypoint' => ['sh', '-c', 'while true; do sleep 1; done']
    )
    @container.start

    set :docker_container, @container.id
  end

  include_context 'clean-up'
end

# Docker always running container
# Overwrite the command so that we can run the tests
shared_context 'with a docker container (override command)' do
  include_context 'shared docker image'

  before(:all) do
    @container = Docker::Container.create(
      'Image' => @image.id,
      'Cmd' => ['sh', '-c', 'while true; do sleep 1; done']
    )
    @container.start

    set :docker_container, @container.id
  end

  include_context 'clean-up'
end
