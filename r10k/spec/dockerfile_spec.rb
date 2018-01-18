require 'spec_helper'

describe 'Dockerfile' do
  before(:all) do
    @image = ::Docker::Image.build_from_dir(File.dirname(File.dirname(__FILE__)))
    set :backend, :docker
    set :docker_image, @image.id
    set :docker_container_create_options, 'Cmd' => ['sh']
  end

  it "should have the maintainer label" do
    expect(@image.json["Config"]["Labels"].has_key?("maintainer"))
  end

  it 'uses the correct OS' do
    expect(os[:family]).to eq('alpine')
  end

  packages = %w(bash git tini)
  packages.each do |pkg|
    describe package(pkg) do
      it { is_expected.to be_installed }
    end
  end

  describe command('git version') do
    its(:stdout) { is_expected.to contain('git') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe package('r10k') do
    it { is_expected.to be_installed.by('gem') }
  end

  describe command('r10k version') do
    its(:stdout) { is_expected.to contain('r10k') }
    its(:exit_status) { is_expected.to eq 0 }
  end

  describe file('/etc/puppetlabs/r10k/r10k.yaml') do
    it { is_expected.to exist }
  end
end
