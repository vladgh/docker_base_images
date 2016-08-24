require 'rainbow'

def version
  `git describe --always --tags`.strip
end

def git_commit
  `git rev-parse --short HEAD`.strip
end

def git_branch
  return ENV['GIT_BRANCH'] if ENV['GIT_BRANCH']
  return ENV['TRAVIS_BRANCH'] if ENV['TRAVIS_BRANCH']
  `git symbolic-ref HEAD --short 2>/dev/null`.strip
end

def git_url
  `git config --get remote.origin.url`.strip
end

def info(message)
  puts Rainbow("==> #{message}").green
end

def warn(message)
  puts Rainbow("==> #{message}").yellow
end

def error(message)
  puts Rainbow("==> #{message}").red
end

def command?(command)
  system("command -v #{command} >/dev/null 2>&1")
end

def version_hash
  @version_hash ||= begin
    v = version
    {}.tap do |h|
      h[:major], h[:minor], h[:patch], h[:rev], h[:rev_hash] = v[1..-1].split(/[.-]/)
    end
  end
end

def increment_version(level)
  v = version_hash.dup
  v[level] = v[level].to_i + 1

  to_zero = LEVELS[LEVELS.index(level) + 1..LEVELS.size]
  to_zero.each { |z| v[z] = 0 }

  v
end

def configure_changelog(config, release: nil)
  config.bug_labels         = 'Type: Bug'
  config.enhancement_labels = 'Type: Enhancement'
  config.future_release     = "v#{release}" if release
end
