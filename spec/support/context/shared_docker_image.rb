shared_context 'shared docker image' do
  before(:all) do
    @image = Docker::Image.build_from_dir(CURRENT_DIRECTORY)
    set :backend, :docker
  end
end
