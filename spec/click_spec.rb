require 'spec_helper'

describe Click do
  it 'should have a version number' do
    Click::VERSION.should_not be_nil
  end
end
