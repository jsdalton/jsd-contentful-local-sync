require 'contentful'
require_relative('../../../app/services/fetch_contentful_data_changes.rb')

describe FetchContentfulDataChanges do
  describe '#call' do
    let(:fetch_contentful_data_changes) { described_class.new }
    let(:result) { fetch_contentful_data_changes.call(**kwargs) }

    shared_examples :verify_result do |expected_num_resources:|
      it 'returns a hash with the appropriate keys' do
        expect(result).to be_a(Hash)
        expect(result).to include(:resources, :sync)
      end

      it 'includes the contentful sync object in the :sync key' do
        expect(result[:sync]).to be_a(Contentful::Sync)
      end

      it 'includes an array of resource objects in the :resources key' do
        expect(result[:resources]).to be_a(Array)
        expect(result[:resources].length).to eq(expected_num_resources)
      end
    end

    context 'when next_sync_url not provided' do
      let(:kwargs) { { next_sync_url: nil } }
      let(:body) { raw_json_fixture 'contentful/initial_sync_response' }
      before :each do
        stub_request(:get, %r{cdn\.contentful\.com\/spaces\/.+\/sync\?initial=true})
          .to_return(status: 200, body: body)
      end

      include_examples :verify_result, expected_num_resources: 3
    end

    context 'when next_sync_url is provided' do
      let(:kwargs) { { next_sync_url: 'https://cdn.contentful.com/spaces/ti1zf61egylr/sync?sync_token=w5ZGw6JFwqZmVcKsE8Kow4grw45QdyYWw7XCqcKrREHCpCp5fcOSw5PDu8KYw4PCsAfDhDvDhsKWw7spwrUfw7ttw4fCu8Ktw6vDt0PCqCzDgBDDg8K6Sy_Dh8KyKFEkwqXCiU7Dqg1VH0dqAsKLXsKrwp1mS8OGw4k' } }
      before :each do
        stub_request(:get, %r{cdn\.contentful\.com\/spaces\/.+\/sync\?sync_token=.+})
          .to_return(status: 200, body: body)
      end

      context 'and there are changes since the last sync' do
        let(:body) { raw_json_fixture 'contentful/subsequent_sync_response' }

        include_examples :verify_result, expected_num_resources: 3
      end

      context 'and there are no changes since the last sync' do
        let(:body) { raw_json_fixture 'contentful/nothing_to_sync_response' }

        include_examples :verify_result, expected_num_resources: 0
      end
    end
  end
end
