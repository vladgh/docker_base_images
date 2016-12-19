# Configure the load path so all dependencies in your Gemfile can be required
require 'bundler/setup'

# Load libraries
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

# Load rake tasks
Rake.add_rakelib 'lib/tasks'

# List all tasks by default
task :default do
  puts `rake -T`
end
