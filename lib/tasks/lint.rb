# Tasks module
module Tasks
  require 'rake/tasklib'

  # Lint tasks
  class Lint < ::Rake::TaskLib
    attr_reader :file_list

    def initialize(options = {})
      @file_list ||= options.fetch(:file_list) unless options.empty?
      define_tasks
    end

    def define_tasks
      # RuboCop
      require 'rubocop/rake_task'
      desc 'Run RuboCop on the tasks and lib directory'
      RuboCop::RakeTask.new(:rubocop) do |task|
        task.patterns = file_list
        task.options  = ['--display-cop-names', '--extra-details']
      end

      # Reek
      require 'reek/rake/task'
      Reek::Rake::Task.new do |task|
        task.source_files  = file_list
        task.fail_on_error = false
        task.reek_opts     = '--wiki-links --color'
      end

      # Ruby Critic
      require 'rubycritic/rake_task'
      RubyCritic::RakeTask.new do |task|
        task.paths = file_list
      end
    end # def define_tasks
  end # class Lint
end # module Tasks
