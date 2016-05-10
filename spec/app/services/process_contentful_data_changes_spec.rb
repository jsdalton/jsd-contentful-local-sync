require_relative('../../../app/services/process_contentful_data_changes')
require_relative('../../../app/stores/contentful_entry_store')

describe ProcessContentfulDataChanges do
  describe '#call' do
    let(:process_contentful_data_changes) { described_class.new }
    let(:contentful_entry_store) { ContentfulEntryStore.new(redis: LocalSyncApp.settings.redis) }
    let(:kwargs) { { resources: resources } }

    context 'when initial is true' do
      # Due to limitations of Marshal dump/load, we'll just reuse the resources
      # created for FetchContentfulDataChanges using webmock
      let(:resources) { FetchContentfulDataChanges.new.call[:resources] }
      let(:body) { raw_json_fixture 'contentful/initial_sync_response' }
      before :each do
        stub_request(:get, %r{cdn\.contentful\.com\/spaces\/.+\/sync\?initial=true})
          .to_return(status: 200, body: body)
        kwargs[:initial] = true
      end

      def expect_contentful_entry_store_to_match_resources
        process_contentful_data_changes.call(**kwargs)
        expect(contentful_entry_store.all.map(&:id)).to contain_exactly(*resources.map(&:id))
      end

      context 'and no local entries exist' do
        before :each do
          expect(contentful_entry_store.all).to be_empty
        end

        it 'creates an entry for each resource' do
          expect_contentful_entry_store_to_match_resources
        end
      end

      context 'and some local entries exist' do
        before :each do
          contentful_entry = ContentfulEntry.new(fields: {}, sys: {})
          contentful_entry_store.save(contentful_entry)
        end

        it 'erases the existing entries before adding the new ones' do
          expect_contentful_entry_store_to_match_resources
        end
      end
    end

    context 'when initial is false' do
      # Due to limitations of Marshal dump/load, we'll just reuse the resources
      # created for FetchContentfulDataChanges using webmock
      let(:resources) { FetchContentfulDataChanges.new.call(next_sync_url: next_sync_url)[:resources] }
      let(:next_sync_url) { 'https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYWw7XCqcKrREHCpCp5fcOSw5PDu8KYw4PCsAfDhDvDhsKWw7spwrUfw7ttw4fCu8Ktw6vDt0PCqCzDgBDDg8K6Sy_Dh8KyKFEkwqXCiU7Dqg1VH0dqAsKLXsKrwp1mS8OGw4k' }
      before :each do
        stub_request(:get, %r{cdn\.contentful\.com\/spaces\/.+\/sync\?sync_token=.+})
          .to_return(status: 200, body: raw_json_fixture('contentful/subsequent_sync_response'))
        kwargs[:initial] = true

        # Populate the local store with some existing entries to test changes against
        contentful_entry_store.import(ruby_fixture('store_data_with_initial_resources'))
      end

      it 'adds the new resource' do
        new_resource = resources[2]
        process_contentful_data_changes.call(**kwargs)
        expect(contentful_entry_store.all.map(&:id)).to include(new_resource.id)
      end

      it 'updates the updated resource' do
        updated_resource = resources[1]
        process_contentful_data_changes.call(**kwargs)
        expect(contentful_entry_store.get(updated_resource.id).fields).to eq(updated_resource.fields)
      end

      it 'removes the deleted resource' do
        deleted_resource = resources[0]
        process_contentful_data_changes.call(**kwargs)
        expect(contentful_entry_store.get(deleted_resource.id)).to be_nil
      end
    end
  end
end
