require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Utils::DockerSharedContext::RunningEntrypointContainer

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  describe package('bash') do
    it { is_expected.to be_installed }
  end

  describe package('minidlna') do
    it { is_expected.to be_installed }
  end

  describe command('minidlnad -V') do
    its(:stdout) { is_expected.to contain('Version') }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
