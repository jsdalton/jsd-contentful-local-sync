require_relative('../models/contentful_entry')
require_relative('../stores/contentful_entry_store')

# A service to process new, updated, and deleted resources against
# the local store
class ProcessContentfulDataChanges
  def initialize(contentful_entry_store: nil)
    @contentful_entry_store =
      contentful_entry_store ||
      ContentfulEntryStore.new(redis: LocalSyncApp.settings.redis)
  end

  def call(resources:, initial: false)
    # Important: Initial sync requires us to clear out the entire local cache
    @contentful_entry_store.delete_all if initial

    resources.each do |resource|
      if resource.type == 'DeletedEntry'
        @contentful_entry_store.delete(resource.id)
      else
        @contentful_entry_store.save(
          ContentfulEntry.from_resource(resource)
        )
      end
    end
  end
end
