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
    @guard.instance_variable_set(:@options, {:notifications => false})
    ::Brakeman.stub(:set_options)
  end

  describe '#start' do
    let(:scanner) { double }
    before(:each) do
      ::Brakeman::Scanner.should_receive(:new).and_return(scanner)
    end

    it 'initializes brakeman by scanning all files' do
      scanner.should_receive(:process)
      @guard.start
    end

    context 'with the run_on_start option' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:run_on_start => true})
      end
      
      it 'runs all checks' do
        scanner.stub(:process).and_return(tracker)
        @guard.should_receive(:run_all)
        @guard.start
      end
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

  describe '#print_failed' do
    before(:each) do
      report.stub(:all_warnings).and_return [double.as_null_object]
    end

    context 'with notifications on' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:notifications => true})
      end

      it 'notifies the user' do
        ::Guard::Notifier.should_receive :notify
        @guard.send :print_failed, report
      end
    end

    context 'with notifications disabled' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:notifications => false})
      end

      it 'does not notify the user' do
        ::Guard::Notifier.should_not_receive :notify
        @guard.send :print_failed, report
      end
    end
  end   
  
  describe '#print_changed' do
    before(:each) do
      report.stub(:all_warnings).and_return [double.as_null_object]
    end

    context 'with notifications on' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:notifications => true})
      end

      it 'notifies the user' do
        ::Guard::Notifier.should_receive :notify
        @guard.send :print_changed, report
      end  
    end
    
    context 'with notifications disabled' do
      before(:each) do
        @guard.instance_variable_set(:@options, {:notifications => false})
      end

      it 'does not notify the user' do
        ::Guard::Notifier.should_not_receive :notify
        @guard.send :print_changed, report
      end
    end
  end
end