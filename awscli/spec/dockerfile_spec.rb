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

  packages = %w(bash findutils git groff less python tini)
  packages.each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed }
    end
  end

  describe command('find --version') do
    its(:stdout) { is_expected.to contain('GNU findutils') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('git version') do
    its(:stdout) { is_expected.to contain('git') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe command('aws --version') do
    its(:stderr) { is_expected.to contain('aws-cli') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe file('/sbin/tini') do
    it { is_expected.to exist }
    it { is_expected.to be_executable }
  end

  describe command('/sbin/tini -h') do
    its(:stdout) { is_expected.to contain('tini') }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
