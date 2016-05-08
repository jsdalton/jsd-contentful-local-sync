require_relative('../stores/contentful_entry_store')

# A service that builds an entries response to return to the client
class BuildEntriesResponse
  def initialize(contentful_entry_store: nil)
    @contentful_entry_store =
      contentful_entry_store ||
      ContentfulEntryStore.new(redis: LocalSyncApp.settings.redis)
  end

  def call
    items = @contentful_entry_store.all
    {
      sys: { type: 'Array' },
      total: items.length,
      items: items.map { |item| { fields: item.fields, sys: item.sys } }
                  .sort { |a, b| created_at(a) <=> created_at(b) }
    }
  end

  private

  def created_at(item)
    DateTime.iso8601(item[:sys][:createdAt])
  end
end
