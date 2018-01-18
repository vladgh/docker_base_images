require 'spec_helper'

describe 'Dockerfile' do
  before(:all) do
    @image = ::Docker::Image.build_from_dir(File.dirname(File.dirname(__FILE__)))
    set :backend, :docker
    set :docker_image, @image.id
    set :docker_container_create_options, 'Entrypoint' => ['sh']
  end
  it "should have the maintainer label" do
    expect(@image.json["Config"]["Labels"].has_key?("maintainer"))
  end

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  describe package('gnupg') do
    it { is_expected.to be_installed }
  end

  describe package('haveged') do
    it { is_expected.to be_installed }
  end

  describe command('gpg --version') do
    its(:stdout) { is_expected.to contain('(GnuPG)') }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
