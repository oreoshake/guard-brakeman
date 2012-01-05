require 'spec_helper'

describe Guard::Brakeman::Runner do
  let(:runner) { Guard::Brakeman::Runner }
  let(:tracker) { mock }
  let(:null_device) { RUBY_PLATFORM.index('mswin') ? 'NUL' : '/dev/null' }

  describe '#run' do
    context "when passed an empty paths list" do
      it "returns false" do
        pending        
        runner.run([], tracker).should be_false
      end
    end

    context 'with a :rvm option' do
      it 'executes cucumber through the rvm versions' do
        pending
        runner.run(['.'], tracker, { :rvm => ['1.8.7', '1.9.2'] })
      end
    end

    context 'with a :cli option' do
      it 'appends the cli arguments when calling cucumber' do
        pending
        runner.run(['.'], tracker, { :cli => "--custom command" })
      end
    end

    context 'with an :output option' do
      it 'appends the output option' do
        pending
        runner.run(['.'], tracker, { :output => 'stuff' })
      end
    end
  end

end
