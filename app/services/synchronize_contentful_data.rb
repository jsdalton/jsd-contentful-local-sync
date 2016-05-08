require_relative('../stores/sync_request_store')
require_relative('../models/sync_request')
require_relative('../services/fetch_contentful_data_changes')
require_relative('../services/process_contentful_data_changes')

# A service to manage the synchronization of remote contentful data with the
# local data store
class SynchronizeContentfulData
  def initialize(fetch_contentful_data_changes: nil,
                 process_contentful_data_changes: nil, sync_request_store: nil)
    @fetch_contentful_data_changes =
      fetch_contentful_data_changes ||
      FetchContentfulDataChanges.new
    @process_contentful_data_changes =
      process_contentful_data_changes ||
      ProcessContentfulDataChanges.new
    @sync_request_store =
      sync_request_store ||
      SyncRequestStore.new(redis: LocalSyncApp.settings.redis)
  end

  def call(initial: false)
    previous_sync_request = @sync_request_store.latest
    next_sync_url = if previous_sync_request && !initial
                      previous_sync_request.next_sync_url
                    end
    changes = @fetch_contentful_data_changes.call(next_sync_url: next_sync_url)

    # If next_sync_url was nil, we are treating this as an initial load, and the
    # processor will need to clear out local entries
    initial = !next_sync_url
    @process_contentful_data_changes.call(resources: changes[:resources],
                                          initial: initial)

    # After the sync has been processed, we want to delete the previous request
    # to ensure it never gets used again
    if previous_sync_request
      @sync_request_store.delete(previous_sync_request.id)
    end

    # The sync request gets saved for use on the next sync
    sync_request = SyncRequest.new(next_sync_url: changes[:sync].next_sync_url,
                                   initial: initial)
    @sync_request_store.save(sync_request)
    sync_request
  end
end
