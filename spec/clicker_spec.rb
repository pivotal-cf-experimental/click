require 'spec_helper'

describe Click::Clicker do
  subject(:clicker) { described_class.new }

  describe '#instance_count' do
    it 'counts instances of a single class' do
      klass = Class.new

      clicker.click!
      expect(clicker.instance_count(klass)).to eq(0)

      obj = klass.new

      clicker.click!
      expect(clicker.instance_count(klass)).to eq(1)

      obj = nil

      clicker.click!
      expect(clicker.instance_count(klass)).to eq(0)
    end

    it 'tracks differences in symbols' do
      difference = 100

      expect {
        difference.times { |i| [Time.now.to_i, i].join('_-_-_').to_sym }
      }.to change {
        clicker.click!
        clicker.instance_count(Symbol)
      }.by_at_least(difference)
    end

    it 'counts BasicObjects as indeterminable' do
      difference = 100
      stuff = []

      expect {
        difference.times { |i| stuff << BasicObject.new }
      }.to change {
        clicker.click!
        clicker.instance_count(Click::Indeterminable)
      }.by_at_least(difference)
    end

    it 'counts objects that have overridden #class as indeterminable' do
      difference = 100
      stuff = []
      klass = Class.new do
        def class
          nil
        end
      end

      expect {
        difference.times { |i| stuff << klass.new }
      }.to change {
        clicker.click!
        clicker.instance_count(Click::Indeterminable)
      }.by_at_least(difference)
    end
  end

  describe '#object_counts' do
    it "groups objects by their class" do
      ObjectSpace.should_receive(:each_object).and_yield(Object.new).and_yield(":)").and_yield(":(")
      Symbol.should_receive(:all_symbols).and_return([:foo, :bar, :baz])

      clicker.click!
      expect(clicker.object_counts).to be_a(Hash)
      expect(clicker.object_counts.to_a).to eq([[Object, 1], [String, 2], [Symbol, 3]])
    end
  end

  describe 'observers' do
    it 'calls before_click and after_click' do
      observer = double(before_click: nil, after_click: nil)
      observer.should_receive(:before_click).with(clicker).ordered
      observer.should_receive(:after_click).with(clicker).ordered

      clicker.add_observer(observer)
      clicker.click!
    end
  end
end
