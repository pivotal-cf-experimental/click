require 'spec_helper'
require 'click/observer'

describe Click::Observer do
  it 'can be included into a class and then attached for callbacks' do
    mod = described_class
    klass = Class.new do
      include mod
    end

    expect {
      clicker = Click::Clicker.new
      clicker.add_observer(klass.new)
      clicker.click!
    }.not_to raise_error
  end
end
