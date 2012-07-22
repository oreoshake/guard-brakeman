require 'guard'
require 'guard/guard'
require 'brakeman'
require 'brakeman/scanner'

module Guard

  # The Brakeman guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_changes`.
  #
  class Brakeman < Guard
    def initialize(watchers = [], options = { })
      super

      if options[:skip_checks]
        options[:skip_checks] = options[:skip_checks].map do |val| 
          # mimic Brakeman::set_options behavior
          val[0,5] == "Check" ? val : "Check" << val
        end
      end

      # chatty implies notifications
      options[:notifications] = true if options[:chatty]

      # TODO mixing the use of this attr, good to match?  Bad to couple?
      @options = {
          :notifications => true,
          :run_on_start => false,
          :chatty => false,
          :min_confidence => 1
      }.update(options)
    end

    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def start
      @scanner_opts = ::Brakeman::set_options({:app_path => '.'}.merge(@options))
      @options.merge!(@scanner_opts)
      
      @scanner = ::Brakeman::Scanner.new(@scanner_opts)

      @tracker = @scanner.process

      if @options[:run_on_start]
        run_all 
      elsif @options[:chatty]
        ::Guard::Notifier.notify("Brakeman is ready to work!", :title => "Brakeman started", :image => :pending)
      end
    end

    # Gets called when all checks should be run.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def run_all
      UI.info 'running all'
      @tracker.run_checks
      print_failed(@tracker.checks)
      throw :task_has_failed if @tracker.checks.all_warnings.any?
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @raise [:task_has_failed] when stop has failed
    #
    def run_on_changes paths
      return run_all unless @tracker.checks

      UI.info "\n\nrescanning #{paths}, running all checks"
      report = ::Brakeman::rescan(@tracker, paths)
      print_changed(report)
      throw :task_has_failed if report.any_warnings?
    end

    private

    def print_failed report
      UI.info "\n------ brakeman warnings --------\n"

      icon = report.all_warnings.count > 0 ? :failed : :success

      all_warnings = reject_below_threshold(report.all_warnings)

      puts all_warnings.sort_by { |w| w.confidence }

      message = "#{all_warnings.count} brakeman findings"

      if @options[:output_files]
        write_report
        message += "\nResults written to #{@options[:output_files]}" 
      end

      if @options[:chatty] && all_warnings.any?
        ::Guard::Notifier.notify(message, :title => "Full Brakeman results", :image => icon) 
      end
    end

    def print_changed report
      UI.info "\n------ brakeman warnings --------\n"
      
      message = ""
      should_alert = false

      fixed_warnings = reject_below_threshold(report.fixed_warnings)
      if fixed_warnings.any?
        icon = :success
        results_notification = "#{fixed_warnings.length} fixed warning(s)\n"
        UI.info(UI.send(:color, results_notification, 'green')) # janky

        should_alert = true 
        message += results_notification

        puts fixed_warnings.sort_by { |w| w.confidence }
        puts
      end

      new_warnings = reject_below_threshold(report.new_warnings)
      if new_warnings.any?
        new_warning_message = "#{new_warnings.length} new warning(s)\n"
        UI.error new_warning_message
        message += new_warning_message

        should_alert = true
        icon = :failed

        puts new_warnings.sort_by { |w| w.confidence }
        puts
      end

      existing_warnings = reject_below_threshold(report.existing_warnings)
      if existing_warnings.any?
        should_alert = true if @options[:chatty]
        icon ||= :pending
        
        existing_warning_message = "#{existing_warnings.length} previous warning(s)\n"
        UI.warning existing_warning_message
        message += existing_warning_message

        puts existing_warnings.sort_by { |w| w.confidence }
      end



      if @options[:output_files]
        write_report
        message += "\nResults written to #{@options[:output_files]}" 
      end

      if @options[:notifications] && should_alert
        ::Guard::Notifier.notify(message.chomp, :title => "Brakeman results", :image => icon) 
      end
    end

    def reject_below_threshold(warnings)
      warnings.reject {|w| w.confidence > (3 - @options[:min_confidence].to_i)}
    end

    def write_report
      @options[:output_files].each_with_index do |output_file, i|
        File.open output_file, "w" do |f|
          f.puts @tracker.report.send(@options[:output_formats][i])
        end
      end
    end
  end
end
