require 'contentful'
require_relative('../../../app/models/contentful_entry')

describe ContentfulEntry do
  let(:resource_data) do
    {
      id: '78o4nLrLrOqUuAQaiMmUy6',
      created_at: DateTime.iso8601('2016-05-07T03:20:52+00:00'),
      # rubocop:disable all
      raw: {'sys'=>
            {'space'=>
             {'sys'=>{'type'=>'Link', 'linkType'=>'Space', 'id'=>'ti1zf61egylr'}},
               'id'=>'78o4nLrLrOqUuAQaiMmUy6',
               'type'=>'Entry',
               'createdAt'=>'2016-05-07T03:20:52.887Z',
               'updatedAt'=>'2016-05-07T03:20:52.887Z',
               'revision'=>1,
               'contentType'=>
             {'sys'=>{'type'=>'Link', 'linkType'=>'ContentType', 'id'=>'product'}}},
            'fields'=>
             {'name'=>{'en-US'=>'Lounge Chair'},
              'description'=>{'en-US'=>'A comfortable lounge chair'},
              'price'=>{'en-US'=>15}}},
      fields: {:name=>'Lounge Chair', :description=>'A comfortable lounge chair', :price=>15}
      # rubocop:enable all
    }
  end
  describe '.from_resource' do
    let(:resource) { instance_double('Contentful::Entry', **resource_data) }
    it 'instantiates a ContentfulEntry' do
      ce = described_class.from_resource(resource)
      expect(ce).to be_a(described_class)
      expect(ce).to have_attributes(
        id: resource_data[:id],
        created_at: resource_data[:created_at],
        fields: resource_data[:fields],
        sys: resource_data[:raw]['sys']
      )
    end
  end
end
