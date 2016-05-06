describe '/api/sync-requests', type: :feature do
  let(:response_json) { as_hash(last_response.body) }

  context 'when client POSTs update sync request' do
    let(:payload) { { type: :update }.to_json  }

    before :each do
      post_json '/api/sync-requests', payload
    end

    it 'responds with status code 200' do
      expect(last_response.status).to eq(200)
    end

    it 'includes type update in the response' do
      expect(response_json).to include('type' => 'update')
    end
  end

  context 'when client POSTs full sync request' do
    let(:payload) { { type: :full }.to_json  }

    before :each do
      post_json '/api/sync-requests', payload
    end

    it 'responds with status code 200' do
      expect(last_response.status).to eq(200)
    end

    it 'includes type full in the response' do
      expect(response_json).to include('type' => 'full')
    end
  end
end

