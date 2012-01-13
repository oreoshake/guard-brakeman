require 'brakeman'

module Guard
  class Brakeman

    # The Cucumber runner handles the execution of the cucumber binary.
    #
    module Runner
      class << self

        # Run the supplied features.
        #
        # @param [Array<String>] paths the feature files or directories
        # @param [Hash] options the options for the execution
        # @option options [Boolean] :bundler use bundler or not
        # @option options [Array<String>] :rvm a list of rvm version to use for the test
        # @option options [Boolean] :notification show notifications
        # @return [Boolean] the status of the execution
        #
        def run(paths, tracker, options = { })
          return false if paths.empty?

          message = options[:message] || (paths == ['.'] ? 'Run brakeman on the whole project' : "Run brakeman checks #{ paths.join(' ') }")
          UI.info message, :reset => true

          report = ::Brakeman.rescan(tracker, paths)
          report.all_warnings.any?
        end
      end
    end
  end
end
