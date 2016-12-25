require 'erb'
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

# Parse ERB Template
def parse_erb(template)
  render = ERB.new(template)
  render.result(binding)
end

# Get external IP
def external_ip
  @external_ip = `dig +short myip.opendns.com @resolver1.opendns.com`.strip
end
