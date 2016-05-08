require_relative('../../../app/services/build_entries_response')

describe BuildEntriesResponse do
  describe '#call' do
    let(:build_entries_response) { described_class.new }
    let(:contentful_entry_store) do
      ContentfulEntryStore.new(redis: LocalSyncApp.settings.redis)
    end

    context 'when entries exist' do
      before :each do
        contentful_entry_store.import(ruby_fixture('store_data_with_initial_resources'))
      end
      it 'returns a properly formatted response hash with the entries' do
        result = build_entries_response.call

        # Verify items
        expect(result[:items].length).to eq(3)
        result[:items].each do |item|
          expect(item).to include(:fields, :sys)
        end

        # Verify metadata
        # Pagination not implemented so don't include these
        # skip: 0,
        # limit: 100,
        expect(result).to include(
          sys: { type: 'Array' },
          total: 3
        )
      end

      it 'sorts the entries by sys.createdAt ascending' do
        result = build_entries_response.call
        result[:items].each_cons(2) do |pair|
          created_at_first = DateTime.iso8601(pair[0][:sys][:createdAt])
          created_at_second = DateTime.iso8601(pair[1][:sys][:createdAt])
          expect(created_at_first).to be < created_at_second
        end
      end
    end

    context 'when entries do not exist' do
      it 'returns a properly formatted response hash with an empty items array' do
        result = build_entries_response.call
        expect(result[:total]).to eq(0)
        expect(result[:items].length).to eq(0)
      end
    end
  end
end
