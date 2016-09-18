task :docker do
  raise 'These tasks require docker to be installed' unless command? 'docker'
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
  docker_image     = "#{REPOSITORY}/#{IMAGE_PREFIX}#{docker_dir}"
  docker_tag       = version.to_s
  docker_tag_short = "#{version_hash[:major]}.#{version_hash[:minor]}.#{version_hash[:patch]}"

  namespace docker_dir.to_sym do |_args|
    RSpec::Core::RakeTask.new(spec: [:docker]) do |t|
      t.pattern = "#{docker_dir}/spec/*_spec.rb"
    end

    desc 'Run Hadolint against the Dockerfile'
    task lint: :docker do
      info "Running Hadolint to check the style of #{docker_dir}/Dockerfile"
      sh "docker run --rm -i lukasmartinelli/hadolint < #{docker_dir}/Dockerfile"
    end

    desc 'Build docker image'
    task build: :docker do
      cmd  = "cd #{docker_dir} && docker build"
      cmd += " --build-arg VERSION=#{docker_tag}"
      cmd += " --build-arg VCS_URL=#{git_url}"
      cmd += " --build-arg VCS_REF=#{git_commit}"
      cmd += " --build-arg BUILD_DATE=#{BUILD_DATE}"

      if NO_CACHE
        info "Ignoring layer cache for #{docker_image}"
        cmd += ' --no-cache'
      end

      info "Building #{docker_image}:#{docker_tag}"
      sh "#{cmd} -t #{docker_image}:#{docker_tag} ."

      info "Tagging #{docker_image}:#{docker_tag_short}"
      sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag} #{docker_image}:#{docker_tag_short}"

      case git_branch
      when 'master'
        info "Tagging #{docker_image}:latest"
        sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag} #{docker_image}:latest"
      else
        info "Tagging #{docker_image}:#{git_branch}"
        sh "cd #{docker_dir} && docker tag #{docker_image}:#{docker_tag} #{docker_image}:#{git_branch}"
      end
    end

    desc 'Publish docker image'
    task push: :docker do
      info "Pushing #{docker_image}:#{docker_tag} to Docker Hub"
      sh "docker push '#{docker_image}:#{docker_tag}'"

      info "Pushing #{docker_image}:#{docker_tag_short} to Docker Hub"
      sh "docker push '#{docker_image}:#{docker_tag_short}'"

      case git_branch
      when 'master'
        info "Pushing #{docker_image}:latest to Docker Hub"
        sh "docker push '#{docker_image}:latest'"
      else
        info "Pushing #{docker_image}:#{git_branch} to Docker Hub"
        sh "docker push '#{docker_image}:#{git_branch}'"
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
