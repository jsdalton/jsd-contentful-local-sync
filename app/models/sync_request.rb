require_relative '../../lib/model'

# A model to save sync requests locally
class SyncRequest < Model
  attribute :next_sync_url, String
  attribute :initial, Boolean
end
