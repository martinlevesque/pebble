require "kemal"
require "sqlite3"
require "uuid"
require "json"
require "./handle_data"
require "./app"

App.logger.info("Starting pebble")
input_events_channel = Channel(String).new
responses_channel = Channel(String).new

database_path = ENV["DATABASE_PATH"] || "./data.db"

db = DB.open "sqlite3://#{database_path}"

init_mutate_data(db, input_events_channel, responses_channel)

def process_mutation(query, input_events_channel, responses_channel)
  input_events_channel.send(query)

  responses_channel.receive.to_json
end

def process_read(db, query)
  result = db.query_all(query) do |rs|
    cur_row = Hash(String, Int64 | String | Float64 | Nil).new

    rs.column_names.each do |column_name|
      cur_row[column_name] = rs.read(Int64 | String | Float64 | Nil)
    end

    cur_row
  end

  result.to_json
end

post "/query" do |env|
  query_type = env.params.json["type"].to_s
  query = env.params.json["query"].to_s

  dynamic_call = {
    "mutation": ->{ process_mutation(query, input_events_channel, responses_channel) },
    "read":     ->{ process_read(db, query) },
  }

  dynamic_call[query_type].call
end

Kemal.run
