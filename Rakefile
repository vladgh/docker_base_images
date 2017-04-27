# Configure the load path so all dependencies in your Gemfile can be required
require 'bundler/setup'

# Include task modules
require 'vtasks/docker'
Vtasks::Docker.new(
  repo: 'vladgh',
  has_build_args: true
)
require 'vtasks/lint'
Vtasks::Lint.new(file_list: FileList['lib/**/*.rb', 'spec/**/*.rb', 'Rakefile'])
require 'vtasks/release'
Vtasks::Release.new(
  write_changelog: true
)

# Display version
desc 'Display version'
task :version do
  require 'vtasks/version'
  include Vtasks::Utils::Semver
  puts "Current version: #{gitver}"
end

# Create a list of contributors from GitHub
desc 'Populate CONTRIBUTORS file'
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end

# List all tasks by default
Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task :default do
  system 'rake -T'
end
