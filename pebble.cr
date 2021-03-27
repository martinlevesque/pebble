require "kemal"
require "sqlite3"
require "uuid"
require "json"
require "./handle_data"
require "./app"

App.logger.info("Starting pebble")
input_events_channel = Channel(String).new
responses_channel = Channel(String).new
db = DB.open "sqlite3://./data.db"

init_handle_data(db, input_events_channel, responses_channel)

post "/query" do |env|
  query_type = env.params.json["type"]
  query = env.params.json["query"].to_s

  input_events_channel.send(query)

  response = responses_channel.receive

  response
end

Kemal.run
