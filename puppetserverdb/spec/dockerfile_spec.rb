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

  describe file('/sbin/tini') do
    it { is_expected.to exist }
    it { is_expected.to be_executable }
  end

  describe command('/sbin/tini --version') do
    its(:stdout) { is_expected.to contain('tini') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe package('puppetserver') do
    it { is_expected.to be_installed }
  end

  describe file('/opt/puppetlabs/bin/puppetserver') do
    it { is_expected.to exist }
    it { is_expected.to be_executable }
  end

  describe command('puppetserver --version') do
    its(:stdout) { is_expected.to contain('puppetserver') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe user('puppet') do
    it { is_expected.to exist }
  end

  describe process('java') do
    its(:user) { is_expected.to eq 'puppet' }
    it { sleep 5; is_expected.to be_running }
  end

  describe package('puppetdb-termini') do
    it { is_expected.to be_installed }
  end

  describe package('hiera-eyaml') do
    it { is_expected.to be_installed.by('gem') }
  end

  describe command('puppetserver gem list') do
    its(:stdout) { is_expected.to match(/hiera-eyaml/) }
  end

  describe 'Dockerfile#config' do
    it 'expose the puppetserver port' do
      expect(@image.json['ContainerConfig']['ExposedPorts']).to include('8140/tcp')
    end
  end
end
