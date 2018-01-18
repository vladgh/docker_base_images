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
