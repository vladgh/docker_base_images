# Tasks module
module Tasks
  require 'rake/tasklib'

  # Release tasks
  class Release < ::Rake::TaskLib
    # Include utility modules
    require 'git'
    include Git
    require 'output'
    include Output
    require 'version'
    include Version

    def initialize
      define_tasks
    end

    # Configure the github_changelog_generator/task
    def changelog(config, release: nil)
      config.bug_labels         = 'Type: Bug'
      config.enhancement_labels = 'Type: Enhancement'
      config.future_release     = "v#{release}" if release
    end

    def define_tasks
      namespace :tag do
        Version::LEVELS.each do |level|
          desc "Tag #{level} version"
          task level.to_sym do
            new_version = bump(level)
            release = "#{new_version[:major]}.#{new_version[:minor]}.#{new_version[:patch]}"

            info 'Check if the repository is clean'
            git_clean_repo

            info 'Tag release'
            sh "git tag --sign v#{release} --message 'Release v#{release}'"
            sh 'git push --follow-tags'
          end # task
        end # Version::LEVELS
      end # namespace :release

      namespace :release do
        Version::LEVELS.each do |level|
          desc "Release #{level} version"
          task level.to_sym do
            new_version = bump(level)
            release = "#{new_version[:major]}.#{new_version[:minor]}.#{new_version[:patch]}"
            release_branch = "release_v#{release.gsub(/[^0-9A-Za-z]/, '_')}"
            initial_branch = git_branch

            info 'Check if the repository is clean'
            git_clean_repo

            info 'Create a new release branch'
            sh "git checkout -b #{release_branch}"

            info 'Generate new changelog'
            begin
              require 'github_changelog_generator/task'
              GitHubChangelogGenerator::RakeTask.new(:unreleased) do |config|
                changelog(config)
              end
            rescue LoadError
              nil # Might be in a group that is not installed
            end
            GitHubChangelogGenerator::RakeTask.new(:latest_release) do |config|
              changelog(config, release: release)
            end
            Rake::Task['latest_release'].invoke

            info 'Push the new changes'
            sh "git commit --gpg-sign --message 'Update change log for v#{release}' CHANGELOG.md"
            sh "git push --set-upstream origin #{release_branch}"

            info 'Waiting for CI to finish'
            sleep 5 until git_ci_status(release_branch) == 'success'

            info 'Merge release branch'
            sh "git checkout #{initial_branch}"
            sh "git merge --gpg-sign --no-ff --message 'Release v#{release}' #{release_branch}"

            info 'Tag release'
            sh "git tag --sign v#{release} --message 'Release v#{release}'"
            sh 'git push --follow-tags'
          end # task
        end # Version::LEVELS
      end # namespace :release
    end # def define_tasks
  end # class Release
end # module Tasks
