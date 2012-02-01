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
    
    @guard.instance_variable_set(:@tracker, tracker)
    ::Brakeman.stub(:set_options)
  end

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
      @guard.stub(:print_failed)
      tracker.should_receive(:run_checks)
      tracker.stub_chain(:checks, :all_warnings, :any?)
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

  context 'notifying users' do
    describe '#print_failed' do
      it 'notifies the user ' do
        ::Guard::Notifier.should_receive :notify
        @guard.send :print_failed, report
      end

      it 'does not notify the user if disabed' do
        ::Guard::Notifier.should_not_receive :notify
        @guard.instance_variable_set(:@options, {:notifications => false})
        @guard.send :print_failed, report
      end
    end    
  end

end