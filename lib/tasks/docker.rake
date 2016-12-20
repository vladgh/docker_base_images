require 'rspec/core/rake_task'

require 'common'
require 'git'
require 'release'

# Docker tasks

task :docker do
  raise 'These tasks require docker to be installed' unless command? 'docker'
end

namespace :docker do
  # VARs
  REPOSITORY   = ENV['DOCKER_REPOSITORY']   || 'vladgh'
  NO_CACHE     = ENV['DOCKER_NO_CACHE']     || false
  BUILD_ARGS   = ENV['DOCKER_BUILD_ARGS']   || true

  # Internals
  BUILD_DATE = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
  IMAGES = Dir.glob('*').select do |dir|
    File.directory?(dir) && File.exist?("#{dir}/Dockerfile")
  end

  desc 'List all Docker images'
  task :list do
    info IMAGES.map { |image| File.basename(image) }
  end

  desc 'Garbage collect unused docker filesystem layers'
  task gc: :docker do
    unless `docker images -f "dangling=true" -q`.empty?
      sh 'docker rmi $(docker images -f "dangling=true" -q)'
    end
  end

  IMAGES.each do |image|
    docker_dir       = File.basename(image)
    docker_image     = "#{REPOSITORY}/#{docker_dir}"
    docker_tag       = version.to_s
    docker_tag_short = "#{version_hash[:major]}.#{version_hash[:minor]}.#{version_hash[:patch]}"

    namespace docker_dir.to_sym do |_args|
      RSpec::Core::RakeTask.new(spec: [:docker]) do |t|
        t.pattern = "#{docker_dir}/spec/*_spec.rb"
      end

      desc 'Run Hadolint against the Dockerfile'
      task lint: :docker do
        info "Running Hadolint to check the style of #{docker_dir}/Dockerfile"
        sh "docker run --rm -i lukasmartinelli/hadolint hadolint --ignore DL3008 --ignore DL3013 - < #{docker_dir}/Dockerfile"
      end

      desc 'Build docker image'
      task build: :docker do
        cmd = "cd #{docker_dir} && docker build"

        if BUILD_ARGS
          cmd += " --build-arg VERSION=#{docker_tag}"
          cmd += " --build-arg VCS_URL=#{git_url}"
          cmd += " --build-arg VCS_REF=#{git_commit}"
          cmd += " --build-arg BUILD_DATE=#{BUILD_DATE}"
        end

        if NO_CACHE
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
      end

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
    end
  end

  [:lint, :build, :push].each do |task_name|
    desc "Run #{task_name} for all images in repository in parallel"
    multitask task_name => IMAGES
      .collect { |image| "#{File.basename(image)}:#{task_name}" }
  end

  [:spec].each do |task_name|
    desc "Run #{task_name} for all images in repository"
    task task_name => IMAGES
      .collect { |image| "#{File.basename(image)}:#{task_name}" }
  end

  # Test everything
  desc 'Run all tests.'
  task test: [
    :lint,
    :spec
  ]
end
