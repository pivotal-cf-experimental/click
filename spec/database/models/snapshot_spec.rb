require 'spec_helper'
require 'click/database'

initialize_models

describe Click::Database::Models::Snapshot do
  describe 'scopes' do
    describe '.after' do
      it 'excludes records prior to the given time' do
        with_in_memory_db do
          described_class.create(timestamp: Date.new(2000))
          later = described_class.create(timestamp: Date.new(2006))

          expect(described_class.after(Date.new(2003)).all).to eq([later])
        end
      end
    end

    describe '.before' do
      it 'excludes records after the given time' do
        with_in_memory_db do
          earlier = described_class.create(timestamp: Date.new(2000))
          described_class.create(timestamp: Date.new(2006))

          expect(described_class.before(Date.new(2003)).all).to eq([earlier])
        end
      end
    end

    it 'can combine scopes' do
      with_in_memory_db do
        described_class.create(timestamp: Date.new(2000))
        middle = described_class.create(timestamp: Date.new(2003))
        described_class.create(timestamp: Date.new(2006))

        expect(described_class.after(Date.new(2001)).before(Date.new(2005)).all).to eq([middle])
      end
    end
  end
end
