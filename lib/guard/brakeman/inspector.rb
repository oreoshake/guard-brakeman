module Guard
  class Brakeman

    # The inspector verifies of the changed paths are valid
    # for Guard::Cucumber.
    #
    module Inspector
      class << self
        def clean paths
          return paths
        end
      end
    end
  end
end