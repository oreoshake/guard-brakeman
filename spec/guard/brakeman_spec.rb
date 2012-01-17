require 'spec_helper'

# TODO
# Barely covers happy case, ignores sad case
# Pending tests
describe Guard::Brakeman do

  let(:default_options) { {:cli => '--stuff'} }
  let(:guard)   { Guard::Brakeman.new }
  let(:runner)  { Guard::Brakeman::Runner }
  let(:tracker) { double }  
  let(:report) { double }

  before(:each) do
    guard.stub(:print_failed)
    guard.instance_variable_set(:@tracker, tracker)
  end

  describe '#initialize'

  describe '#start' do
    it 'sets up and runs brakeman' do
      ::Brakeman.should_receive(:run)
      guard.start
    end
  end

  describe '#run_all' do
    it 'runs all checks' do
      guard.stub(:clean_report?).and_return(true) # happy case
      ::Brakeman.should_receive(:run).and_return(tracker)
      guard.run_all
    end
  end

  describe '#reload'

  describe '#run_on_change' do
    before(:each) do
      report.stub(:all_warnings).and_return([])
    end

    it 'runs Brakeman with all files' do
      runner.should_receive(:run).with('.', tracker, anything).and_return(report)
      guard.run_on_change('.')
    end

    it 'runs Brakeman with single file' do
      runner.should_receive(:run).with(['files/file'], tracker, anything).and_return(report)
      guard.run_on_change(['files/file'])
    end
  end
end