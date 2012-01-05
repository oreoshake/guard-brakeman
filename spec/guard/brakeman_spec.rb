require 'spec_helper'

describe Guard::Brakeman do

  let(:default_options) do
    {
        :all_after_pass => true,
        :all_on_start   => true,
        :keep_failed    => true,
        :cli            => '--no-profile --color --format progress --strict'
    }
  end

  let(:guard) { Guard::Brakeman.new }
  let(:runner) { Guard::Brakeman::Runner }
  let(:tracker) {mock}  

  before(:each) do
    guard.tracker = tracker
  end

  describe '#initialize' do
    context 'when no options are provided' do
      it 'sets a default :cli option' do
        guard.options[:cli].should eql '--no-profile --color --format progress --strict'
      end
    end

    context 'with other options than the default ones' do
      let(:guard) { Guard::Brakeman.new(nil, { :all_after_pass => false,
                                               :all_on_start   => false,
                                               :keep_failed    => false,
                                               :cli            => '--color' }) }

      it 'sets the provided :cli option' do
        guard.options[:cli].should eql '--color'
      end
    end
  end

  describe '#start' do
    it 'calls #run_all' do
      ::Brakeman.should_receive(:run)
      guard.start
    end
  end

  describe '#run_all' do
    it 'runs all features' do
      runner.should_receive(:run).with(['.'], tracker, anything).and_return(true)
      guard.run_all
    end

    it 'cleans failed memory if passed' do
      runner.should_receive(:run).with(['.'], tracker, anything).and_return(false)
      expect { guard.run_on_change(['.']) }.to throw_symbol :task_has_failed

      runner.should_receive(:run).with(['file'], tracker, anything).and_return(true)
      guard.run_on_change(['file'])
    end

    it 'saves failed features' do
      guard.stub(:get_failed_paths).and_return ['features/foo']  

      runner.should_receive(:run).with(['.'], tracker, anything).and_return(false)
      expect { guard.run_all }.to throw_symbol :task_has_failed

      runner.should_receive(:run).with(['features/bar', 'features/foo'], tracker, anything).and_return(true)
      guard.run_on_change(['features/bar'])
    end

    context 'with the :cli option' do
      let(:guard) { Guard::Brakeman.new([], { :cli => '--color' }) }

      it 'directly passes :cli option to runner' do
        runner.should_receive(:run).with(['.'], tracker, default_options.merge(:cli     => '--color',
                                                                             :message => 'Running all features')).and_return(true)
        guard.run_all
      end
    end

    context 'with a :run_all option' do
      let(:guard) { Guard::Brakeman.new([], { :rvm => ['1.8.7', '1.9.2'],
                                              :cli => '--color',
                                              :run_all => { :cli => '--format progress' } }) }

      it 'allows the :run_all options to override the default_options' do
        guard.tracker = tracker

        runner.should_receive(:run).with(anything, tracker, hash_including(:cli => '--format progress', :rvm => ['1.8.7', '1.9.2'])).and_return(true)
        guard.run_all
      end
    end
  end

  describe '#reload' do
    it 'clears failed_path' do
      runner.should_receive(:run).with(['features/foo'], tracker, anything).and_return(false)
      expect { guard.run_on_change(['features/foo']) }.to throw_symbol :task_has_failed
      guard.reload
      runner.should_receive(:run).with(['features/bar'], tracker, anything).and_return(true)
      guard.run_on_change(['features/bar'])
    end
  end

  describe '#run_on_change' do
    it 'runs Brakeman with all file' do
      runner.should_receive(:run).with(['.'], tracker, anything).and_return(true)
      guard.run_on_change(['.'])
    end

    it 'runs Brakeman with single file' do
      runner.should_receive(:run).with(['files/file'], tracker, anything).and_return(true)
      guard.run_on_change(['files/file'])
    end
  end
end