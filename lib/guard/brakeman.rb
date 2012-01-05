require 'guard'
require 'guard/guard'

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
    # @option options [String] :cli any arbitrary Brakeman CLI arguments
    # @option options [Array<String>] :rvm a list of rvm version to use for the test
    # @option options [Boolean] :notification show notifications
    # @option options [Boolean] :all_after_pass run all features after changed features pass
    # @option options [Boolean] :all_on_start run all the features at startup
    # @option options [Boolean] :keep_failed Keep failed features until they pass
    # @option options [Boolean] :run_all run override any option when running all specs
    # @option options [Boolean] :format use a different brakeman format when running individual features
    # @option options [Boolean] :output specify the output file
    # @option options [Boolean] :disabled specify tests to skip (comma separated)"
    #
    def initialize(watchers = [], options = { })
      super
      @options = {
          :all_after_pass => true,
          :all_on_start   => true,
          :keep_failed    => true,
          :cli            => '--no-profile --color --format progress --strict'
      }.update(options)

      @last_failed  = false
      @failed_paths = []
    end

    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def start
      @tracker = ::Brakeman.run :app_path => 'default_app'
    end

    def tracker=tracker
      @tracker = tracker
    end

    # Gets called when all specs should be run.
    #
    # @raise [:task_has_failed] when stop has failed
    #
    def run_all
      passed = Runner.run(['.'], @tracker, options.merge(options[:run_all] || { }).merge(:message => 'Running all features'))

      if passed
        @failed_paths = []
      else
        @failed_paths = get_failed_paths(@tracker)
        # @failed_paths = @tracker.checks.all_warnings
        # puts @tracker.checks.all_warnings.inspect
        # puts @tracker.checks.errors.inspect
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
      paths += @failed_paths if @options[:keep_failed]
      paths   = Inspector.clean(paths)
      # options = @options[:change_format] ? change_format(@options[:change_format]) : @options
      options = @options
      passed  = Runner.run(paths, @tracker, paths.include?('ROOT DIRECTORY') ? options.merge({ :message => 'Checking all files' }) : options)


        # puts @tracker.checks.all_warnings.inspect
        # puts @tracker.checks.errors.inspect
      # if passed
      #   # clean failed paths memory
      #   @failed_paths -= paths if @options[:keep_failed]
      #   # run all the specs if the changed specs failed, like autotest
      #   run_all if @last_failed && @options[:all_after_pass]
      # else
      #   # remember failed paths for the next change
      #   @failed_paths += read_failed_features if @options[:keep_failed]
      #   # track whether the changed feature failed for the next change
      #   @last_failed = true
      # end

      throw :task_has_failed unless passed
    end

    private

    def get_failed_paths tracker
      # TODO
    end
  end
end
