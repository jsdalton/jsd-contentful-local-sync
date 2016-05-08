require_relative '../../lib/model'

# A model to save contentful entries locally
class ContentfulEntry < Model
  def self.from_resource(resource)
    new(
      id: resource.id,
      created_at: resource.created_at,
      sys: resource.raw['sys'],
      fields: resource.fields
    )
  end

  attribute :fields, Hash
  attribute :sys, Hash
end
