require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Utils::DockerSharedContext::RunningEntrypointContainer

  packages = %w(curl gnupg haveged xz)
  packages.each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed }
    end
  end

  describe command('curl --version') do
    its(:stdout) { is_expected.to contain('curl') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('gpg --version') do
    its(:stdout) { is_expected.to contain('GnuPG') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('haveged --help') do
    its(:stdout) { is_expected.to contain('haveged') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('xz --version') do
    its(:stdout) { is_expected.to contain('XZ Utils') }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
