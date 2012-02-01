When /^I add a watched file$/ do
  sleep 5
  append_to_file('app/controllers/application_controller.rb', '  ')
  sleep 5
end

