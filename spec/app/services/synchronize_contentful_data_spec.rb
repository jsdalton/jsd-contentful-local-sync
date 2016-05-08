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
    let(:next_sync_url) { 'https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=abc' }
    let(:sync_request_store) { SyncRequestStore.new(redis: LocalSyncApp.settings.redis) }

    # Configure instance doubles to avoid hitting the API
    let(:contentful_sync) do
      instance_double(
        'Contentful::Sync', 'completed?': true, next_sync_url: next_sync_url
      )
    end
    let(:response_from_fetch) { { sync: contentful_sync, resources: [{ foo: 'bar' }] } }
    let(:fetch_contentful_data_changes) do
      instance_double(
        'FetchContentfulDataChanges', call: response_from_fetch
      )
    end
    let(:process_contentful_data_changes) do
      instance_double('ProcessContentfulDataChanges', call: nil)
    end

    context 'when initial is true' do
      let(:kwargs) { { initial: true } }

      context 'and sync request exist' do
        let(:previous_sync_request) do
          SyncRequest.new(next_sync_url: 'https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=def',
                          initial: true)
        end
        before :each do
          sync_request_store.save(previous_sync_request)
        end

        it 'calls the fetch with next_sync_url nil' do
          synchronize_contentful_data.call(**kwargs)
          expect(fetch_contentful_data_changes).to have_received(:call).with(include(next_sync_url: nil))
        end
        it 'calls the processor with the result resources' do
          synchronize_contentful_data.call(**kwargs)
          expect(process_contentful_data_changes)
            .to have_received(:call)
            .with(include(resources: response_from_fetch[:resources], initial: true))
        end
        it 'deletes the current sync request' do
          synchronize_contentful_data.call(**kwargs)
          expect(sync_request_store.get(previous_sync_request.id)).to be_nil
        end
        it 'creates a new sync request with the sync url and initial true' do
          result = synchronize_contentful_data.call(**kwargs)
          expect(result).to be_a(SyncRequest)
          expect(sync_request_store.get(result.id).next_sync_url).to eq(next_sync_url)
          expect(sync_request_store.get(result.id).initial).to be(true)
        end
      end
      context 'and sync request does not exist' do
        it 'calls the fetcher with nil' do
          synchronize_contentful_data.call(**kwargs)
          expect(fetch_contentful_data_changes).to have_received(:call).with(include(next_sync_url: nil))
        end
        it 'calls the processor with the result resources and initial true' do
          synchronize_contentful_data.call(**kwargs)
          expect(process_contentful_data_changes)
            .to have_received(:call)
            .with(include(resources: response_from_fetch[:resources], initial: true))
        end
        it 'creates and returns a new sync request with the next sync url' do
          result = synchronize_contentful_data.call(**kwargs)
          expect(result).to be_a(SyncRequest)
          expect(sync_request_store.get(result.id).next_sync_url).to eq(next_sync_url)
          expect(sync_request_store.get(result.id).initial).to be(true)
        end
      end
    end

    context 'when iniitial is false' do
      context 'and sync request exists' do
        let(:previous_sync_request) do
          SyncRequest.new(next_sync_url: 'https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=def',
                          initial: true)
        end
        before :each do
          sync_request_store.save(previous_sync_request)
        end

        it 'calls the fetch with the next sync url from the previous sync request' do
          synchronize_contentful_data.call
          expect(fetch_contentful_data_changes)
            .to have_received(:call)
            .with(include(next_sync_url: previous_sync_request.next_sync_url))
        end
        it 'calls the processor with the result resources and initial false' do
          synchronize_contentful_data.call
          expect(process_contentful_data_changes)
            .to have_received(:call)
            .with(include(resources: response_from_fetch[:resources], initial: false))
        end
        it 'deletes the previous sync request' do
          synchronize_contentful_data.call
          expect(sync_request_store.get(previous_sync_request.id)).to be_nil
        end
        it 'creates a new sync request with the new next sync url' do
          result = synchronize_contentful_data.call
          expect(result).to be_a(SyncRequest)
          expect(sync_request_store.get(result.id).next_sync_url).to eq(next_sync_url)
          expect(sync_request_store.get(result.id).initial).to be(false)
        end
      end
      context 'and sync request does not exist' do
        it 'calls the fetcher with nil' do
          synchronize_contentful_data.call
          expect(fetch_contentful_data_changes).to have_received(:call).with(include(next_sync_url: nil))
        end
        it 'calls the processor with the result resources and initial true' do
          synchronize_contentful_data.call
          expect(process_contentful_data_changes)
            .to have_received(:call)
            .with(include(resources: response_from_fetch[:resources], initial: true))
        end
        it 'creates and returns a new sync request with the next sync url' do
          result = synchronize_contentful_data.call
          expect(result).to be_a(SyncRequest)
          expect(sync_request_store.get(result.id).next_sync_url).to eq(next_sync_url)
          expect(sync_request_store.get(result.id).initial).to be(true)
        end
      end
    end
  end
end
