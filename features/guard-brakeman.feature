@aruba @announce
Feature: Guard brakeman 

	Background:
		Given I am using the default Guardfile
		And I have a rails app

	Scenario: Starting guard-brakeman smoke test
		When I run `guard`
		Then the output should contain "running all"


	Scenario: Triggering a change event smoke test
    	When I append text to a watched file
    	Then the output should contain "running something else"