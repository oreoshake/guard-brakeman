require 'spec_helper'

# TODO
# Barely covers happy case, ignores sad case
# Pending tests
describe Guard::Brakeman do
  let(:default_options) { {:cli => '--stuff'} }
  let(:tracker) { double().as_null_object }  
  let(:report) { double().as_null_object }

  before(:each) do
    @guard = Guard::Brakeman.new
    @guard.stub(:print_failed)
    @guard.instance_variable_set(:@tracker, tracker)
    ::Brakeman.stub(:set_options)
  end

  describe '#initialize'

  describe '#start' do
    it 'initializes brakeman by scanning all files' do
      scanner = double
      ::Brakeman::Scanner.should_receive(:new).and_return(scanner)
      scanner.should_receive(:process)

      @guard.start
    end
  end

  describe '#run_all' do
    it 'runs all checks' do
      tracker.should_receive(:run_checks)
      tracker.stub_chain(:checks, :all_warnings, :empty?)
      @guard.run_all
    end
  end

  describe '#reload'

  describe '#run_on_change' do
    it 'rescans changed files, and checks all files' do
      ::Brakeman.should_receive(:rescan).with(tracker, ['files/file']).and_return(report)
      report.stub(:any_warnings?)
      @guard.run_on_change(['files/file'])
    end
  end
end