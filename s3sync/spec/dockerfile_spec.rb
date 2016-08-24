require 'spec_helper'

CURRENT_DIRECTORY = File.dirname(File.dirname(__FILE__))

describe 'Dockerfile' do
  include_context 'with a perpetual docker container'

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  describe package('inotify-tools') do
    it { is_expected.to be_installed }
  end
end
