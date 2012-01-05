require 'spec_helper'

describe Guard::Brakeman::Runner do
  let(:runner) { Guard::Brakeman::Runner }
  let(:null_device) { RUBY_PLATFORM.index('mswin') ? 'NUL' : '/dev/null' }

  describe '#run' do
    context "when passed an empty paths list" do
      it "returns false" do
        runner.run([]).should be_false
      end
    end

    context 'with a :rvm option' do
      it 'executes cucumber through the rvm versions' do
        runner.should_receive(:system).with(
            "rvm 1.8.7,1.9.2 exec bundle exec brakeman ." 
        )
        runner.run(['.'], { :rvm => ['1.8.7', '1.9.2'] })
      end
    end

    context 'with a :cli option' do
      it 'appends the cli arguments when calling cucumber' do
        runner.should_receive(:system).with(
            "bundle exec brakeman --custom command ."
        )
        runner.run(['.'], { :cli => "--custom command" })
      end
    end

    context 'with an :output option' do
      it 'does not add the guard notification listener' do
        runner.should_receive(:system).with(
            "bundle exec brakeman -o stuff ."
        )
        runner.run(['.'], { :output => 'stuff' })
      end
    end
  end

end
