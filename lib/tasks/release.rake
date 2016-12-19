require 'common'
require 'release'

# Release tasks

# GitHub CHANGELOG generator
# Might not be always present, for example with
# `bundle install --without development`
begin
  # GitHub CHANGELOG generator
  require 'github_changelog_generator/task'
  GitHubChangelogGenerator::RakeTask.new(:unreleased) do |config|
    configure_changelog(config)
  end
rescue LoadError
  warn 'github_changelog_generator gem is not installed'
end

# Release task
namespace :release do
  LEVELS = [:major, :minor, :patch].freeze
  LEVELS.each do |level|
    desc "Increment #{level} version"
    task level.to_sym do
      v = version_increment(level)
      release = "#{v[:major]}.#{v[:minor]}.#{v[:patch]}"
      release_branch = "release_v#{release.gsub(/[^0-9A-Za-z]/, '_')}"
      initial_branch = git_branch

      # Check if the repo is clean
      git_clean_repo

      # Create a new release branch
      sh "git checkout -b #{release_branch}"

      # Generate new changelog
      GitHubChangelogGenerator::RakeTask.new(:latest_release) do |config|
        configure_changelog(config, release: release)
      end
      Rake::Task['latest_release'].invoke

      # Push the new changes
      sh "git commit --gpg-sign --message 'Release v#{release}' CHANGELOG.md"
      sh "git push --set-upstream origin #{release_branch}"

      # Waiting for CI to finish
      puts 'Waiting for CI to finish'
      sleep 5 until git_ci_status(release_branch) == 'success'

      # Merge release branch
      sh "git checkout #{initial_branch}"
      sh "git merge --gpg-sign --no-ff --message 'Release v#{release}' #{release_branch}"

      # Tag release
      sh "git tag --sign v#{release} --message 'Release v#{release}'"
      sh 'git push --follow-tags'
    end
  end
end

# Version
desc 'Display version'
task :version do
  puts "Current version: #{version}"
end

# Create a list of contributors from GitHub
desc 'Populate CONTRIBUTORS file'
task :contributors do
  system("git log --format='%aN' | sort -u > CONTRIBUTORS")
end
