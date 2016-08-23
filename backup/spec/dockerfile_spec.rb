require 'spec_helper'

CURRENT_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a perpetual docker container'

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  describe package('git') do
    it { is_expected.to be_installed }
  end

  describe package('gnupg') do
    it { is_expected.to be_installed }
  end

  describe package('xz') do
    it { is_expected.to be_installed }
  end

  describe command('aws --version') do
    its(:stderr) { is_expected.to contain('aws-cli') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('git version') do
    its(:stdout) { is_expected.to contain('git') }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
