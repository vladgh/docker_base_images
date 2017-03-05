# Version module
module Version
  # Semantic version (from git tags)
  FULL   = (`git describe --always --tags 2>/dev/null`.chomp || '0.0.0-0-0').freeze
  LEVELS = [:major, :minor, :patch].freeze

  # Create semantic version hash
  def semver
    @semver ||= begin
      {}.tap do |h|
        h[:major], h[:minor], h[:patch], h[:rev], h[:rev_hash] = FULL[1..-1].split(/[.-]/)
      end
    end
  end

  # Increment the version number
  def bump(level)
    new_version = semver.dup
    new_version[level] = new_version[level].to_i + 1
    to_zero = LEVELS[LEVELS.index(level) + 1..LEVELS.size]
    to_zero.each { |z| new_version[z] = 0 }
    new_version
  end
end # module Version
