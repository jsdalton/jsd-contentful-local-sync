require 'virtus'
require 'securerandom'

# A base class that defines some required attributes
# for models to be stored in the model store
class Model
  include Virtus::Model

  attribute :id, String
  attribute :created_at, DateTime

  def initialize(**attributes)
    attributes[:id] ||= SecureRandom.uuid
    attributes[:created_at] ||= DateTime.now
    super(attributes)
  end
end
