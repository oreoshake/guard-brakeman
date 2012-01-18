require 'guard'
require 'guard/guard'
require 'brakeman'
require 'brakeman/scanner'

module Guard

  # The Brakeman guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_change`.
  #
  class Brakeman < Guard
    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def start
      options = ::Brakeman::set_options(:app_path => '.')
      @scanner = ::Brakeman::Scanner.new(options)
      @tracker = @scanner.process
    end

    # Gets called when all checks should be run.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def run_all
      puts 'running all'
      @tracker.run_checks
      print_failed(@tracker.checks)
      throw :task_has_failed if @tracker.checks.all_warnings.any?
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @raise [:task_has_failed] when stop has failed
    #
    def run_on_change(paths)
      puts "rescanning #{paths}, running all checks"
      report = ::Brakeman::rescan(@tracker, paths)
      print_failed(report)
      throw :task_has_failed if report.any_warnings?
    end

    private

    def print_failed report
      puts "\n------ brakeman warnings --------\n"
      report.all_warnings.each do |w|
        puts w.to_row
      end
    end
  end
end
