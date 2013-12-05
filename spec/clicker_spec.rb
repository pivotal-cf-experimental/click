require 'spec_helper'

describe Click::Clicker do
  Given(:session_name) { SecureRandom.uuid }
  Given(:clicker) { described_class.new(session_name) }

  describe '#session_name' do
    Then { clicker.session_name == session_name }
  end

  describe '#instance_count' do
    Given(:klass) { Class.new }

    describe 'with no instances' do
      When { clicker.click! }

      Then { clicker.instance_count(klass) == 0 }
    end

    describe 'with instances' do
      Given!(:object) { klass.new }

      When { clicker.click! }

      Then { clicker.instance_count(klass) == 1 }
    end

    describe 'symbols' do
      Given { clicker.click! }
      Given!(:original_symbol_count) { clicker.instance_count(Symbol) }

      When { 100.times { |i| [Time.now.to_i, i].join('_-_').to_sym }; clicker.click! }

      Then { clicker.instance_count(Symbol) >= original_symbol_count + 100 }
    end

    describe 'BasicObject' do
      Given { clicker.click! }
      Given!(:original_count) { clicker.instance_count(Click::Indeterminable) }

      When { stuff = 25.times.map { BasicObject.new }; clicker.click! }

      Then { clicker.instance_count(Click::Indeterminable) >= original_count + 25 }
    end

    describe 'objects that poorly override #class' do
      # This test was flaking out with the Given setup. *shrug*
      before do
        klass = Class.new do
          def class
            nil
          end
        end
        clicker.click!
        @original_count = clicker.instance_count(Click::Indeterminable)

        @stuff = 33.times.map { klass.new }
      end

      When { clicker.click! }

      Then { clicker.instance_count(Click::Indeterminable) >= @original_count + 33 }
    end
  end

  describe '#object_counts' do
    Given do
      ObjectSpace.stub(:each_object).and_yield(Object.new).and_yield(":)").and_yield(":(")
      Symbol.stub(:all_symbols).and_return([:foo, :bar, :baz])
    end

    When { clicker.click! }

    Then { clicker.object_counts == {Object => 1, String => 2, Symbol => 3} }
    And { expect(ObjectSpace).to have_received(:each_object).with(no_args) }
    And { expect(Symbol).to have_received(:all_symbols).with(no_args) }
  end

  describe 'observers' do
    Given(:observer) { double(on_add: nil, before_click: nil, after_click: nil) }

    When { clicker.add_observer(observer) }

    Then { expect(observer).to have_received(:on_add).with(clicker) }

    describe 'after click!' do
      When { clicker.click! }

      Then { expect(observer).to have_received(:before_click).with(clicker) }
      Then { expect(observer).to have_received(:after_click).with(clicker) }
    end
  end
end
