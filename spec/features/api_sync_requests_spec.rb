describe '/api/sync-requests', type: :feature do
  let(:response_json) { as_hash(last_response.body) }
  let(:contentful_entry_store) { ContentfulEntryStore.new(redis: LocalSyncApp.settings.redis) }
  let(:sync_request_store) { SyncRequestStore.new(redis: LocalSyncApp.settings.redis) }

  context 'when client executes POST /api/sync-requests' do
    # Stub requests that goes out for sync
    context 'with empty JSON request payload' do
      let(:body) { raw_json_fixture 'contentful/initial_sync_response' }
      before :each do
        stub_request(:get, %r{cdn\.contentful\.com\/spaces\/.+\/sync\?initial=true})
          .to_return(status: 200, body: body)
      end

      it 'responds with status code 200' do
        post '/api/sync-requests'
        expect(last_response.status).to eq(200)
      end

      context 'when local entries exist' do
        # These will be example changed resources in the executed sync
        let(:deleted_resource_id) { '5Nyuw68I8MCQ2sgI48UaeQ' }
        let(:created_resource_id) { '6tF2LfRmU0koWuUK2eQmqI' }

        before :each do
          # Load up stores with initial data
          contentful_entry_store.import(ruby_fixture('store_data_with_initial_resources'))
          sync_request_store.import(ruby_fixture('sync_request_store_with_previous_sync'))
        end

        # Since this is a subsequent sync, we need to stub out a modified response
        let(:body) { raw_json_fixture 'contentful/subsequent_sync_response' }
        before :each do
          stub_request(:get, %r{cdn\.contentful\.com\/spaces\/.+\/sync\?sync_token=.+})
            .to_return(status: 200, body: body)
        end

        it 'includes initial false in the response' do
          post '/api/sync-requests'
          puts JSON.pretty_generate(response_json)
          expect(response_json).to include('initial' => false)
        end

        it 'updates the store' do
          post '/api/sync-requests'
          expect(contentful_entry_store.get(deleted_resource_id)).to be_nil
          expect(contentful_entry_store.get(created_resource_id).id).to eq(created_resource_id)
        end
      end
    end

    context 'with initial: true request payload' do
      let(:body) { raw_json_fixture 'contentful/initial_sync_response' }
      let(:payload) { { initial: :true }.to_json }
      before :each do
        stub_request(:get, %r{cdn\.contentful\.com\/spaces\/.+\/sync\?initial=true})
          .to_return(status: 200, body: body)
      end

      it 'responds with status code 200' do
        post_json '/api/sync-requests', payload
        expect(last_response.status).to eq(200)
      end

      it 'includes type full in the response' do
        post_json '/api/sync-requests', payload
        expect(response_json).to include('initial' => true)
      end
    end

    context 'when Contentful client times out' do
      before :each do
        stub_request(:get, %r{cdn\.contentful\.com\/})
          .to_raise(SocketError)
      end
      it 'responds with status code 504' do
        post '/api/sync-requests'
        expect(last_response.status).to eq(504)
      end
    end
  end
end
