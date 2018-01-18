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
    its(:stderr) { is_expected.to contain('haveged') }
    its(:exit_status) { is_expected.to eq 1 }
  end

  describe command('xz --version') do
    its(:stdout) { is_expected.to contain('XZ Utils') }
    its(:exit_status) { is_expected.to eq 0 }
  end
end
