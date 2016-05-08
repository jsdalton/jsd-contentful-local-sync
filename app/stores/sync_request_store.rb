require_relative('../models/sync_request')
require_relative('../../lib/model_store')

# A store to hold sync requests (in redis)
class SyncRequestStore
  MODEL_CLS = SyncRequest
  include ModelStore
end
