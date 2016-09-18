require 'rspec/core/rake_task'

require_relative 'lib/common'

# VARs
REPOSITORY   = ENV['DOCKER_REPOSITORY']   || 'vladgh'
IMAGE_PREFIX = ENV['DOCKER_IMAGE_PREFIX'] || ''
NO_CACHE     = ENV['DOCKER_NO_CACHE']     || false

# Internals
BUILD_DATE = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
IMAGES = Dir.glob('*').select do |dir|
  File.directory?(dir) && File.exist?("#{dir}/Dockerfile")
end

# RuboCop
require 'rubocop/rake_task'
desc 'Run RuboCop on the tasks and lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = FileList['{lib,rakelib,spec}/**/*.{rb,rake}', 'Rakefile']
end

# Reek
require 'reek/rake/task'
Reek::Rake::Task.new do |task|
  task.source_files  = FileList['{lib,rakelib,spec}/**/*.{rb,rake}', 'Rakefile']
  task.fail_on_error = false
  task.reek_opts     = '-U'
end

# Ruby Critic
require 'rubycritic/rake_task'
RubyCritic::RakeTask.new do |task|
  task.paths = FileList['{lib,rakelib,spec}/**/*.{rb,rake}', 'Rakefile']
end

# GitHub CHANGELOG generator
require 'github_changelog_generator/task'
GitHubChangelogGenerator::RakeTask.new(:unreleased) do |config|
  configure_changelog(config)
end

# Version
desc 'Display version'
task :version do
  puts "Current version: #{version}"
end

# Test everything
desc 'Run all tests.'
task test: [
  :rubocop,
  :lint,
  :spec
]

# List all tasks by default
task :default do
  puts `rake -T`
end
