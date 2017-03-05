# Git module
module Git
  GITHUB_TOKEN = ENV['GITHUB_TOKEN']

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
end # module Git
