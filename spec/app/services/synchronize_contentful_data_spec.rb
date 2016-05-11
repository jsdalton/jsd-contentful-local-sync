require_relative('../../../app/services/synchronize_contentful_data')
require_relative('../../../app/models/sync_request')
require_relative('../../../app/stores/sync_request_store')

describe SynchronizeContentfulData do
  describe '#call' do
    let(:synchronize_contentful_data) do
      described_class.new(
        fetch_contentful_data_changes: fetch_contentful_data_changes,
        process_contentful_data_changes: process_contentful_data_changes
      )
    end
    let(:sync_request_store) { SyncRequestStore.new(redis: LocalSyncApp.settings.redis) }

    # The (mock) URL to get returned from Contentful for the next sync
    let(:new_next_sync_url) { 'https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=abc' }

    # Configure a few instance doubles to avoid hitting the API during tests
    let(:contentful_sync) do
      instance_double(
        'Contentful::Sync', 'completed?': true, next_sync_url: new_next_sync_url
      )
    end
    let(:mock_response_from_fetch) { { sync: contentful_sync, resources: [{ id: 'foobar' }] } }
    let(:fetch_contentful_data_changes) do
      instance_double(
        'FetchContentfulDataChanges', call: mock_response_from_fetch
      )
    end
    let(:process_contentful_data_changes) do
      instance_double('ProcessContentfulDataChanges', call: nil)
    end

    # Minor variants of these examples are used in all the synchronize service tests (below)
    shared_examples :verify_sync do |expected_initial:, expect_sync_request_deleted:|
      it 'calls the fetch service with the expected next_sync_url value' do
        synchronize_contentful_data.call(**kwargs)
        expect(fetch_contentful_data_changes)
          .to have_received(:call)
          .with(include(next_sync_url: expected_sync_url_used))
      end

      it 'calls the processor service and passes the resources received from the fetch service' do
        synchronize_contentful_data.call(**kwargs)
        expect(process_contentful_data_changes)
          .to have_received(:call)
          .with(include(resources: mock_response_from_fetch[:resources]))
      end

      it 'calls the processor service and passes the correct initial value' do
        synchronize_contentful_data.call(**kwargs)
        expect(process_contentful_data_changes)
          .to have_received(:call)
          .with(include(initial: expected_initial))
      end

      if expect_sync_request_deleted
        it 'deletes the previous sync request' do
          synchronize_contentful_data.call(**kwargs)
          expect(sync_request_store.get(previous_sync_request.id)).to be_nil
        end
      end

      it 'creates a new sync request with the sync url and the expected initial value' do
        result = synchronize_contentful_data.call(**kwargs)
        expect(result).to be_a(SyncRequest)
        expect(sync_request_store.get(result.id).next_sync_url).to eq(new_next_sync_url)
        expect(sync_request_store.get(result.id).initial).to be(expected_initial)
      end
    end

    context 'when initial is true' do
      let(:kwargs) { { initial: true } }

      context 'and previous sync request exists' do
        let(:previous_sync_request) do
          SyncRequest.new(next_sync_url: 'https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=def',
                          initial: true)
        end
        before :each do
          sync_request_store.save(previous_sync_request)
        end

        include_examples :verify_sync, expected_initial: true, expect_sync_request_deleted: true do
          let(:expected_sync_url_used) { nil }
        end
      end

      context 'and previous sync request does not exist' do
        include_examples :verify_sync, expected_initial: true, expect_sync_request_deleted: false do
          let(:expected_sync_url_used) { nil }
        end
      end
    end

    context 'when iniitial is false' do
      let(:kwargs) { {} }

      context 'and previous sync request exists' do
        let(:previous_sync_request) do
          SyncRequest.new(next_sync_url: 'https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=def',
                          initial: true)
        end
        before :each do
          sync_request_store.save(previous_sync_request)
        end

        include_examples :verify_sync, expected_initial: false, expect_sync_request_deleted: true do
          let(:expected_sync_url_used) { previous_sync_request.next_sync_url }
        end
      end

      context 'and previous sync request does not exist' do
        include_examples :verify_sync, expected_initial: true, expect_sync_request_deleted: false do
          let(:expected_sync_url_used) { nil }
        end
      end
    end
  end
end
