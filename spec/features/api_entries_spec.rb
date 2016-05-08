describe '/api/entries', type: :feature do
  let(:response_json) { as_hash(last_response.body) }
  let(:contentful_entry_store) { ContentfulEntryStore.new(redis: LocalSyncApp.settings.redis) }
  let(:sync_request_store) { SyncRequestStore.new(redis: LocalSyncApp.settings.redis) }

  context 'when client executes GET /api/entries' do
    let(:expected_response) { ruby_fixture('response_object_with_initial_data') }

    before :each do
      # Load up store with initial data
      contentful_entry_store.import(ruby_fixture('store_data_with_initial_resources'))

      # Execute the request
      get '/api/entries'
    end

    it 'responds with status code 200' do
      expect(last_response.status).to eq(200)
    end

    it 'returns a properly formatted JSON object of entries' do
      expect(response_json).to eq(expected_response)
    end
  end

  context 'when client executes DELETE /api/entries' do
    before :each do
      # Load up store with initial data
      contentful_entry_store.import(ruby_fixture('store_data_with_initial_resources'))
      sync_request_store.import(ruby_fixture('sync_request_store_with_previous_sync'))

      # Execute the request
      delete '/api/entries'
    end

    it "responds with status 'ok' in the JSON" do
      expect(as_hash(last_response.body)).to eq('status' => 'ok')
    end

    it 'responds with status code 200' do
      expect(last_response.status).to eq(200)
    end

    it 'clears out both stores' do
      expect(contentful_entry_store.all).to be_empty
      expect(sync_request_store.all).to be_empty
    end
  end
end
