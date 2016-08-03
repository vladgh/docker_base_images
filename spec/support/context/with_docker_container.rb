shared_context 'with a docker container' do
  include_context 'shared docker image'

  before(:all) do
    @container = Docker::Container.create('Image' => @image.id)
    @container.start

    set :docker_container, @container.id
  end

  after(:all) do
    @container.kill
    @container.delete(force: true)
  end
end
