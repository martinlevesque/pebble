# require "sqlite3"
require "./app"

def init_mutate_data(db, channel, responses_channel)
  spawn do
    loop do
      received_query = channel.receive
      cleaned_query = received_query.gsub("\\\"", "\"")
      result = db.exec(cleaned_query).to_s

      responses_channel.send(result)
    end
  end
end
