require_relative('../models/contentful_entry')
require_relative('../../lib/model_store')

# A store to hold contentful entries (in redis)
class ContentfulEntryStore
  MODEL_CLS = ContentfulEntry
  include ModelStore
end
