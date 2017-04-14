require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include Vtasks::Utils::DockerSharedContext::Container

  describe package('puppetdb-termini') do
    it { is_expected.to be_installed }
  end
end
