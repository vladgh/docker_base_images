require 'spec_helper'

DOCKER_IMAGE_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a dummy docker container'

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  describe package('bash') do
    it { is_expected.to be_installed }
  end

  describe package('inotify-tools') do
    it { is_expected.to be_installed }
  end

  describe command('inotifywait --help') do
    its(:stdout) { is_expected.to contain('inotifywait') }
    its(:exit_status) { is_expected.to eq 1 }
  end
end
