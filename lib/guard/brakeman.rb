require 'guard'
require 'guard/guard'
require 'brakeman'

module Guard

  # The Brakeman guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_change`.
  #
  class Brakeman < Guard

    autoload :Runner, 'guard/brakeman/runner'
    autoload :Inspector, 'guard/brakeman/inspector'

    # Initialize Guard::Brakeman.
    #
    # @param [Array<Guard::Watcher>] watchers the watchers in the Guard block
    # @param [Hash] options the options for the Guard
    # @option options [Boolean] :notification show notifications
    # @option options [Boolean] :format use a different brakeman format when running individual features - not implemented
    # @option options [Boolean] :output specify the output file - not implemented
    # @option options [Array<String>] :disabled specify tests to skip (comma separated) - not implemented"
    #
    def initialize(watchers = [], options = { })
      super
      @last_failed  = false
      @failed_paths = []
    end

    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def start
      @tracker = ::Brakeman.run :app_path => '.'
      print_failed @tracker
    end

    def tracker=tracker
      @tracker = tracker
    end

    # Gets called when all specs should be run.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def run_all
      puts 'running all'
      @tracker = ::Brakeman.run :app_path => '.'
      
      passed = @tracker.checks.all_warnings.empty? && @tracker.checks.errors.empty?

      print_failed @tracker

      if passed
        @failed_paths = []
      else
        @failed_paths = get_failed_paths(@tracker)
      end

      @last_failed = !passed

      throw :task_has_failed unless passed
    end

    # Gets called when the Guard should reload itself.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def reload
      @failed_paths = []
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @raise [:task_has_failed] when stop has failed
    #
    def run_on_change(paths)
      report = Runner.run(paths, @tracker, options)
      passed = !report.all_warnings.any?

      print_failed report

      if passed
        @failed_paths -= paths if @options[:keep_failed]
      else
        @failed_paths += get_failed_paths if @options[:keep_failed]
        @last_failed = true
      end

      throw :task_has_failed unless passed
    end

    private

    def get_failed_paths tracker
    end

    def print_failed tracker
      checks = tracker.is_a?(::Brakeman::Tracker) ? tracker.checks.all_warnings : tracker.all_warnings
      checks.each do |w|
        puts w.to_row
      end
    end
  end
end
