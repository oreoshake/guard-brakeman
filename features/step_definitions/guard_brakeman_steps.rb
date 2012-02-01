When /^I add a watched file$/ do
  `echo ' ' >> tmp/aruba/default_app/app/controllers/application_controller.rb`
  # append_to_file('app/controllers/application_controller.rb', '  ')
  # write_file('app/controllers/application_controller2.rb', 'class Stuff; end')
end

