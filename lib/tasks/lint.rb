require 'rake'
require 'rake/tasklib'
require 'rubocop/rake_task'
require 'reek/rake/task'
require 'rubycritic/rake_task'

module Tasks
  # Lint tasks
  class Lint < ::Rake::TaskLib
    attr_reader :source_files

    def initialize
      define_tasks
    end

    # Compose a list of Ruby files
    def source_files
      @source_files ||= FileList[
        'lib/**/*.rb',
        'spec/**/*.rb',
        'Rakefile'
      ].exclude('spec/fixtures/**/*')
    end

    def define_tasks
      # RuboCop
      desc 'Run RuboCop on the tasks and lib directory'
      RuboCop::RakeTask.new(:rubocop) do |task|
        task.patterns = source_files
        task.options  = ['--display-cop-names', '--extra-details']
      end

      # Reek
      Reek::Rake::Task.new do |task|
        task.source_files = source_files
        task.fail_on_error = false
        task.reek_opts     = '--wiki-links --color'
      end

      # Ruby Critic
      RubyCritic::RakeTask.new do |task|
        task.paths = source_files
      end
    end
  end # class Lint
end # module Tasks
