# A service to retrieve contentful sync changes from the Contentful API
class FetchContentfulDataChanges
  def initialize(client: nil)
    @client = client || LocalSyncApp.settings.contentful
  end

  def call(next_sync_url: nil)
    sync = @client.sync(next_sync_url || { initial: true, type: 'Entry' })
    resources = []
    sync.each_item do |resource|
      resources << resource
    end
    { sync: sync, resources: resources }
  end
end
