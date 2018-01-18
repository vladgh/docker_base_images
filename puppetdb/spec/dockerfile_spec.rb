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

  it 'uses the correct version of Ubuntu' do
    os_version = command('cat /etc/lsb-release').stdout
    expect(os_version).to include('16.04')
    expect(os_version).to include('Ubuntu')
  end

  describe package('puppet-agent') do
    it { is_expected.to be_installed }
  end

  describe command('puppet --version') do
    its(:stdout) { is_expected.to contain('.') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe package('puppetdb') do
    it { is_expected.to be_installed }
  end

  describe command('puppetdb --version') do
    its(:stdout) { is_expected.to contain('puppetdb') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe file('/sbin/tini') do
    it { is_expected.to exist }
    it { is_expected.to be_executable }
  end

  describe command('/sbin/tini --version') do
    its(:stdout) { is_expected.to contain('tini') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe 'Dockerfile#config' do
    it 'expose the puppetserver port' do
      expect(@image.json['ContainerConfig']['ExposedPorts']).to include('8080/tcp')
      expect(@image.json['ContainerConfig']['ExposedPorts']).to include('8081/tcp')
    end
  end
end
