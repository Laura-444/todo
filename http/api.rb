require 'sinatra/base'

class Api < Sinatra::Base
  get '/tasks' do
    tasks = [
      { id: 'f099e72c-72b5-4562-a42c-abe4ef873a91' },
      { id: '61eac763-3dbc-4263-ba28-2c63aa2cea19' },
      { id: '2d9b114e-4565-4f85-9cc3-6d10a99eb315' },
    ]

    [
      200,
      { 'Content-Type' => 'application/json' },
      [tasks.to_json],
    ]
  end

  post '/tasks' do
    task = JSON.parse request.body.read
    [
      200, { 'Content-Type' => 'application/json' },
      [task.to_json],
    ]
  rescue JSON::ParserError
    [
      400,
      { 'Content-Type' => 'application/json' },
      [{ error: 'Json malformed' }.to_json],
    ]
  end
end
