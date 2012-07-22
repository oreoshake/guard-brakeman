When /^I start guard$/ do
  run_interactive(unescape('guard'))
  sleep 5
end

When /^I edit a watched file$/ do
  append_to_file 'app/controllers/application_controller.rb', '  '
  sleep 1
end

Then /^guard should rescan the application$/ do
  type "e" # exit
  assert_partial_output "rescanning app/controllers/application_controller.rb, running all checks", all_output
end

Then /^guard should scan the application$/ do
  type "e" #exit
  assert_partial_output "Indexing call sites...", all_output
end