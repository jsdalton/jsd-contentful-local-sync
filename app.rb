require 'sinatra/base'
require 'sinatra/contrib'

class LocalSyncApp < Sinatra::Application
  register Sinatra::Contrib

  get '/' do
    "Hello, world!"
  end

  get '/api' do
    json({ status: :ok })
  end

  post '/api/sync-requests' do
    type = request_payload['type'] || 'update'
    json({ type: type })
  end

  helpers do
    def request_payload
      request.body.rewind
      JSON.parse request.body.read
    end
  end
end
