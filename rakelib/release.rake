namespace :release do
  LEVELS = [:major, :minor, :patch].freeze
  LEVELS.each do |level|
    desc "Increment #{level} version"
    task level.to_sym do
      v       = increment_version(level)
      release = "#{v[:major]}.#{v[:minor]}.#{v[:patch]}"

      GitHubChangelogGenerator::RakeTask.new(:latest_release) do |config|
        configure_changelog(config, release: release)
      end
      Rake::Task['latest_release'].invoke
      sh "git commit --gpg-sign --message 'Release v#{release}' CHANGELOG.md"

      sh "git tag --sign v#{release} --message 'Release v#{release}'"
      sh 'git push --follow-tags'
    end
  end
end
