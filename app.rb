require 'sinatra/base'
require 'sinatra/contrib'
require "sinatra/config_file"
require "redis"

require_relative('./app/services/build_entries_response')
require_relative('./app/services/synchronize_contentful_data')
require_relative('./app/stores/contentful_entry_store')
require_relative('./app/stores/sync_request_store')

class LocalSyncApp < Sinatra::Application
  register Sinatra::Contrib
  register Sinatra::ConfigFile

  config_file './config.yml'

  configure do
    set :redis, Proc.new {
      Redis.new(
        host: settings.redis_host,
        port: settings.redis_port,
        db: settings.redis_db,
      )
    }

    set :contentful, Proc.new {
      Contentful::Client.new(
        access_token: settings.contentful_access_token,
        space: settings.contentful_space,
        default_locale: settings.contentful_default_locale
      )
    }
  end

  # Hello world on the home page
  get '/' do
    "Hello, world!"
  end

  # A status check on the API endpoint
  get '/api' do
    json({ status: :ok })
  end

  # Fetches all the entries from the local store
  get '/api/entries' do
    json(BuildEntriesResponse.new.call)
  end

  # Clears out the local entry store and any previous sync requests
  delete '/api/entries' do
    contentful_entry_store = ContentfulEntryStore.new(redis: settings.redis)
    sync_request_store = SyncRequestStore.new(redis: settings.redis)

    # Clear 'em out!
    contentful_entry_store.delete_all
    sync_request_store.delete_all

    json({ status: :ok })
  end

  # Initiaties a new sync request and populates the local store
  post '/api/sync-requests' do
    initial = !!payload['initial']
    begin
      sync_request = SynchronizeContentfulData.new.call(initial: initial)
    rescue SocketError => e
      return 504
    end

    json(sync_request.attributes)
  end

  helpers do
    def payload
      request.body.rewind
      body = request.body.read
      body.empty? ? {} : JSON.parse(body)
    end
  end
end
