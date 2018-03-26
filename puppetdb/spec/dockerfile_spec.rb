require 'spec_helper'

describe 'Dockerfile' do
  before(:all) do
    @image = ::Docker::Image.build_from_dir(File.dirname(File.dirname(__FILE__)))
    set :backend, :docker
    set :docker_image, @image.id
    set :docker_container_create_options, {'Healthcheck' => {'Test' => ['NONE']}}
  end

  it "should have the maintainer label" do
    expect(@image.json["Config"]["Labels"].has_key?("maintainer"))
  end

  describe package('puppetdb') do
    it { is_expected.to be_installed }
  end

  describe command('puppetdb --version') do
    its(:stdout) { is_expected.to contain('puppetdb') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe 'Dockerfile#config' do
    it 'expose the puppetserver port' do
      expect(@image.json['ContainerConfig']['ExposedPorts']).to include('8080/tcp')
      expect(@image.json['ContainerConfig']['ExposedPorts']).to include('8081/tcp')
    end
  end
end
