require 'spec_helper'

CURRENT_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a docker container'

  it 'uses the correct version of Ubuntu' do
    os_version = command('cat /etc/lsb-release').stdout
    expect(os_version).to include('16.04')
    expect(os_version).to include('Ubuntu')
  end

  describe package('puppetserver') do
    it { is_expected.to be_installed }
  end

  describe user('puppet') do
    it { should exist }
  end

  describe file('/opt/puppetlabs/bin/puppetserver') do
    it { should exist }
    it { should be_executable }
  end

  describe command('puppetserver --version') do
    its(:stdout) { is_expected.to contain('puppetserver') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe process('java') do
    its(:user) { is_expected.to eq 'puppet' }
    it { sleep 5; is_expected.to be_running }
  end

  describe 'Dockerfile#config' do
    it 'should expose the puppetserver port' do
      expect(@image.json['ContainerConfig']['ExposedPorts']).to include('8140/tcp')
    end
  end
end
