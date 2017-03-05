# Tasks module
module Tasks
  require 'rake/tasklib'

  # Docker tasks
  class Docker < ::Rake::TaskLib
    # Include utility modules
    require 'git'
    include Git
    require 'output'
    include Output
    require 'system'
    include System
    require 'version'
    include Version

    DOCKER_REPOSITORY = ENV['DOCKER_REPOSITORY'] || 'vladgh'
    DOCKER_NO_CACHE   = ENV['DOCKER_NO_CACHE']   || false
    DOCKER_BUILD_ARGS = ENV['DOCKER_BUILD_ARGS'] || true
    DOCKER_BUILD_DATE = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')

    def initialize
      define_tasks
    end

    def define_tasks
      check_docker

      list_images
      garbage_collect

      run_task
      run_task_parallel

      namespace :docker do
        require 'rspec/core/rake_task'

        docker_images.each do |image|
          docker_dir       = File.basename(image)
          docker_image     = "#{DOCKER_REPOSITORY}/#{docker_dir}"
          docker_tag_full  = Version::FULL.to_s
          docker_tag_long  = "#{semver[:major]}.#{semver[:minor]}.#{semver[:patch]}"
          docker_tag_minor = "#{semver[:major]}.#{semver[:minor]}"
          docker_tag_major = "#{semver[:major]}"

          namespace docker_dir.to_sym do |_args|
            RSpec::Core::RakeTask.new(spec: [:docker]) do |task|
              task.pattern = "#{docker_dir}/spec/*_spec.rb"
            end

            desc 'Run Hadolint against the Dockerfile'
            task lint: :docker do
              info "Running Hadolint to check the style of #{docker_dir}/Dockerfile"
              sh "docker container run --rm -i lukasmartinelli/hadolint hadolint --ignore DL3008 --ignore DL3013 - < #{docker_dir}/Dockerfile"
            end

            desc 'Build docker image'
            task build: :docker do
              cmd = "cd #{docker_dir} && docker image build"

              if DOCKER_BUILD_ARGS
                cmd += " --build-arg VERSION=#{docker_tag_full}"
                cmd += " --build-arg VCS_URL=#{git_url}"
                cmd += " --build-arg VCS_REF=#{git_commit}"
                cmd += " --build-arg BUILD_DATE=#{DOCKER_BUILD_DATE}"
              end

              if DOCKER_NO_CACHE
                info "Ignoring layer cache for #{docker_image}"
                cmd += ' --no-cache'
              end

              info "Building #{docker_image}:#{docker_tag_full}"
              sh "#{cmd} -t #{docker_image}:#{docker_tag_full} ."

              next unless git_branch == 'master' && ENV['TRAVIS_PULL_REQUEST'] == 'false'
              info "Tagging #{docker_image}:#{docker_tag_long} image"
              sh "cd #{docker_dir} && docker image tag #{docker_image}:#{docker_tag_full} \
                #{docker_image}:#{docker_tag_long}"

              info "Tagging #{docker_image}:#{docker_tag_minor} image"
              sh "cd #{docker_dir} && docker image tag #{docker_image}:#{docker_tag_full} \
                #{docker_image}:#{docker_tag_minor}"

              info "Tagging #{docker_image}:#{docker_tag_major} image"
              sh "cd #{docker_dir} && docker image tag #{docker_image}:#{docker_tag_full} \
                #{docker_image}:#{docker_tag_major}"

              info "Tagging #{docker_image}:latest"
              sh "cd #{docker_dir} && docker image tag #{docker_image}:#{docker_tag_full} \
                #{docker_image}:latest"
            end # task build

            desc 'Publish docker image'
            task push: :docker do
              next unless ENV['TRAVIS_PULL_REQUEST'] == 'false'
              info "Pushing #{docker_image}:#{docker_tag_full} to Docker Hub"
              sh "docker image push #{docker_image}:#{docker_tag_full}"

              next unless git_branch == 'master'
              info "Pushing #{docker_image}:#{docker_tag_long} to Docker Hub"
              sh "docker image push #{docker_image}:#{docker_tag_long}"

              info "Pushing #{docker_image}:#{docker_tag_minor} to Docker Hub"
              sh "docker image push #{docker_image}:#{docker_tag_minor}"

              info "Pushing #{docker_image}:#{docker_tag_major} to Docker Hub"
              sh "docker image push #{docker_image}:#{docker_tag_major}"

              info "Pushing #{docker_image}:latest to Docker Hub"
              sh "docker image push #{docker_image}:latest"
            end
          end # task push
        end # docker_images.each
      end # namespace :docker
    end # def define_tasks

    # Run a task for all images
    def run_task
      [:spec].each do |task_name|
        desc "Run #{task_name} for all images in repository"
        task task_name => docker_images
          .collect { |image| "docker:#{File.basename(image)}:#{task_name}" }
      end
    end

    # Run a task for all images in parallel
    def run_task_parallel
      [:lint, :build, :push].each do |task_name|
        desc "Run #{task_name} for all images in repository in parallel"
        multitask task_name => docker_images
          .collect { |image| "docker:#{File.basename(image)}:#{task_name}" }
      end
    end

    # List all folders containing Dockerfiles
    def docker_images
      @docker_images = Dir.glob('*').select do |dir|
        File.directory?(dir) && File.exist?("#{dir}/Dockerfile")
      end
    end

    # Check Docker is installed
    def check_docker
      task :docker do
        raise 'These tasks require docker to be installed' unless command? 'docker'
      end
    end

    # List all images
    def list_images
      namespace :docker do
        desc 'List all Docker images'
        task :list do
          info docker_images.map { |image| File.basename(image) }
        end
      end
    end

    # Garbage collect
    def garbage_collect
      namespace :docker do
        desc 'Garbage collect unused docker filesystem layers'
        task gc: :docker do
          sh 'docker image prune'
        end
      end
    end
  end # class Docker
end # module Tasks
