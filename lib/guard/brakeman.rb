require 'guard'
require 'guard/guard'
require 'brakeman'
require 'brakeman/scanner'

module Guard

  # The Brakeman guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_change`.
  #
  class Brakeman < Guard
    def initialize(watchers = [], options = { })
      super
      @options = {
          :notifications => true
      }.update(options)
    end

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
      return run_all unless @tracker.checks

      puts "rescanning #{paths}, running all checks"
      report = ::Brakeman::rescan(@tracker, paths)
      print_changed(report)
      throw :task_has_failed if report.any_warnings?
    end

    private

    def print_failed report
      UI.warning "\n------ brakeman warnings --------\n"

      Notifier.notify("#{report.all_warnings.count} brakeman findings", :title => "Brakeman results", :image => :pending) if @options[:notifications]
      puts report.all_warnings.sort_by { |w| w.confidence }
    end

    def print_changed report
      UI.info "\n------ brakeman warnings --------\n"

      unless report.fixed_warnings.empty?
        message = "#{report.fixed_warnings.length} fixed warning(s)"
        Notifier.notify(message, :title => "Brakeman results", :image => :success) if @options[:notifications]
        UI.info(message + ":")
        puts report.fixed_warnings.sort_by { |w| w.confidence }
        puts
      end

      unless report.new_warnings.empty?
        message = "#{report.new_warnings.length} new warning(s)"
        Notifier.notify(message, :title => "Brakeman results", :image => :failed) if @options[:notifications]
        UI.warning message + ":"
        puts report.new_warnings.sort_by { |w| w.confidence }
        puts
      end

      unless report.existing_warnings.empty?
        message = "#{report.existing_warnings.length} previous warning(s)"
        Notifier.notify(message, :title => "Brakeman results", :image => :pending) if @options[:notifications]
        UI.warning message + ":"
        puts report.existing_warnings.sort_by { |w| w.confidence }
      end
    end
  end
end
