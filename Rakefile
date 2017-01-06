# Configure the load path so all dependencies in your Gemfile can be required
require 'bundler/setup'

# VARs
DOCKER_REPOSITORY = ENV['DOCKER_REPOSITORY'] || 'vladgh'
DOCKER_NO_CACHE   = ENV['DOCKER_NO_CACHE']   || false
DOCKER_BUILD_ARGS = ENV['DOCKER_BUILD_ARGS'] || true
DOCKER_BUILD_DATE = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')

# Semantic version (from git tags)
VERSION = (`git describe --always --tags 2>/dev/null`.chomp || '0.0.0-0-0').freeze

require 'rainbow'

# Debug message
def debug(message)
  puts Rainbow("==> #{message}").green if $DEBUG
end

# Information message
def info(message)
  puts Rainbow("==> #{message}").green
end

# Warning message
def warn(message)
  puts Rainbow("==> #{message}").yellow
end

# Error message
def error(message)
  puts Rainbow("==> #{message}").red
end

# Check if command exists
def command?(command)
  system("command -v #{command} >/dev/null 2>&1")
end

# Compose a list of Ruby files
def lint_files_list
  @lint_files_list = FileList[
    'lib/**/*.rb',
    'spec/**/*.rb',
    'Rakefile'
  ].exclude('spec/fixtures/**/*')
end

def version_hash
  @version_hash ||= begin
    {}.tap do |h|
      h[:major], h[:minor], h[:patch], h[:rev], h[:rev_hash] = VERSION[1..-1].split(/[.-]/)
    end
  end
end

# Get git short commit hash
def git_commit
  `git rev-parse --short HEAD`.strip
end

# Get the branch name
def git_branch
  return ENV['GIT_BRANCH'] if ENV['GIT_BRANCH']
  return ENV['TRAVIS_BRANCH'] if ENV['TRAVIS_BRANCH']
  return ENV['CIRCLE_BRANCH'] if ENV['CIRCLE_BRANCH']
  `git symbolic-ref HEAD --short 2>/dev/null`.strip
end

# Get the URL of the origin remote
def git_url
  `git config --get remote.origin.url`.strip
end

# Get the CI Status (needs https://hub.github.com/)
def git_ci_status(branch = 'master')
  `hub ci-status #{branch}`.strip
end

# Check if the repo is clean
def git_clean_repo
  # Check if there are uncommitted changes
  unless system 'git diff --quiet HEAD'
    abort('ERROR: Commit your changes first.')
  end

  # Check if there are untracked files
  unless `git ls-files --others --exclude-standard`.to_s.empty?
    abort('ERROR: There are untracked files.')
  end

  true
end

# List all folders containing Dockerfiles
def docker_images
  @docker_images = Dir.glob('*').select do |dir|
    File.directory?(dir) && File.exist?("#{dir}/Dockerfile")
  end
end

task :docker do
  raise 'These tasks require docker to be installed' unless command? 'docker'
end

namespace :docker do
  desc 'List all Docker images'
  task :list do
    info docker_images.map { |image| File.basename(image) }
  end

  desc 'Garbage collect unused docker filesystem layers'
  task gc: :docker do
    unless `docker images -f "dangling=true" -q`.empty?
      sh 'docker rmi $(docker images -f "dangling=true" -q)'
    end
  end

  require 'rspec/core/rake_task'

  docker_images.each do |image|
    docker_dir       = File.basename(image)
    docker_image     = "#{DOCKER_REPOSITORY}/#{docker_dir}"
    docker_tag       = VERSION.to_s
    docker_tag_short = "#{version_hash[:major]}.#{version_hash[:minor]}.#{version_hash[:patch]}"

    namespace docker_dir.to_sym do |_args|
      RSpec::Core::RakeTask.new(spec: [:docker]) do |task|
        task.pattern = "#{docker_dir}/spec/*_spec.rb"
      end

      desc 'Run Hadolint against the Dockerfile'
      task lint: :docker do
        info "Running Hadolint to check the style of #{docker_dir}/Dockerfile"
        sh "docker run --rm -i lukasmartinelli/hadolint hadolint --ignore DL3008 --ignore DL3013 - < #{docker_dir}/Dockerfile"
      end

      desc 'Build docker image'
      task build: :docker do
        cmd = "cd #{docker_dir} && docker build"

        if build_args
          cmd += " --build-arg VERSION=#{docker_tag}"
          cmd += " --build-arg VCS_URL=#{git_url}"
          cmd += " --build-arg VCS_REF=#{git_commit}"
          cmd += " --build-arg BUILD_DATE=#{DOCKER_BUILD_DATE}"
        end

        if DOCKER_NO_CACHE
          info "Ignoring layer cache for #{docker_image}"
          cmd += ' --no-cache'
        end

        info "Building #{docker_image}:#{docker_tag}"
        sh "#{cmd} -t #{docker_image}:#{docker_tag} ."

        info "Tagging #{docker_image}:#{docker_tag_short}"
        sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag} #{docker_image}:#{docker_tag_short}"

        if git_branch == 'master'
          info "Tagging #{docker_image}:latest"
          sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag} #{docker_image}:latest"
        end
      end # task build

      desc 'Publish docker image'
      task push: :docker do
        info "Pushing #{docker_image}:#{docker_tag} to Docker Hub"
        sh "docker push '#{docker_image}:#{docker_tag}'"

        info "Pushing #{docker_image}:#{docker_tag_short} to Docker Hub"
        sh "docker push '#{docker_image}:#{docker_tag_short}'"

        if git_branch == 'master'
          info "Pushing #{docker_image}:latest to Docker Hub"
          sh "docker push '#{docker_image}:latest'"
        end
      end
    end # task push
  end # docker_images.each
end # namespace :docker

[:lint, :build, :push].each do |task_name|
  desc "Run #{task_name} for all images in repository in parallel"
  multitask task_name => docker_images
    .collect { |image| "docker:#{File.basename(image)}:#{task_name}" }
end

[:spec].each do |task_name|
  desc "Run #{task_name} for all images in repository"
  task task_name => docker_images
    .collect { |image| "docker:#{File.basename(image)}:#{task_name}" }
end

# RuboCop
require 'rubocop/rake_task'
desc 'Run RuboCop on the tasks and lib directory'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = lint_files_list
  task.options  = ['--display-cop-names', '--extra-details']
end

# Reek
require 'reek/rake/task'
Reek::Rake::Task.new do |task|
  task.source_files  = lint_files_list
  task.fail_on_error = false
  task.reek_opts     = '--wiki-links --color'
end

# Ruby Critic
require 'rubycritic/rake_task'
RubyCritic::RakeTask.new do |task|
  task.paths = lint_files_list
end

# Display version
desc 'Display version'
task :version do
  puts "Current version: #{VERSION}"
end

# Create a list of contributors from GitHub
desc 'Populate CONTRIBUTORS file'
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end

# List all tasks by default
Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task :default do
  puts `rake -T`
end
