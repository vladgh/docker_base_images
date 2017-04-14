require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Utils::DockerSharedContext::Container

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
