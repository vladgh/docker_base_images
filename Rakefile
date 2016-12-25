# Configure the load path so all dependencies in your Gemfile can be required
require 'bundler/setup'

# Add ./lib to the load path
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')

# Local libraries
require 'tasks/docker'
Tasks::Docker.new
require 'tasks/lint'
Tasks::Lint.new
require 'tasks/release'
Tasks::Release.new

# List all tasks by default
Rake::Task[:default].clear if Rake::Task.task_defined?(:default)
task :default do
  puts `rake -T`
end
