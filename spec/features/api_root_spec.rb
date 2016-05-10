describe '/api', type: :feature do
  context 'when client executes GET /api' do
    before :each do
      get '/api'
    end

    it "responds with status 'ok' in the JSON" do
      expect(as_hash(last_response.body)).to eq('status' => 'ok')
    end

    it 'responds with status code 200' do
      expect(last_response.status).to eq(200)
    end

    it 'responds with a JSON content type' do
      expect(last_response.headers['Content-Type']).to eq('application/json')
    end
  end
end
