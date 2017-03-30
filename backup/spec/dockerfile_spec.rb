require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Docker::SharedContext::RunningCommandContainer

  describe package('gnupg') do
    it { is_expected.to be_installed }
  end

  describe package('haveged') do
    it { is_expected.to be_installed }
  end

  describe package('xz') do
    it { is_expected.to be_installed }
  end
end
