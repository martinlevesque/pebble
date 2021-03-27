require "amqp-client"
require "sqlite3"
require "./app"

db = DB.open "sqlite3://./data.db"

spawn do
  AMQP::Client.start("amqp://guest:guest@localhost") do |conn|
    conn.channel do |ch|
      q = ch.queue("my-queue")

      q.subscribe(no_ack: false) do |msg|
        App.logger.debug("Handle data: received #{msg.body_io.to_s}")
        body = JSON.parse(msg.body_io.to_s)

        response = begin
          query_to_exec = body["query"].to_s.gsub("\\\"", "\"")
          result = db.exec(query_to_exec).to_s

          {"result": "success", "msg": result}
        rescue ex
          {"result": "error", "msg": ex.message}
        end

        event_name = body["event"].to_s

        event_queue = ch.queue(event_name, durable = false, auto_delete = true)
        event_queue.publish(response.to_json)
        # event_queue.delete

        ch.basic_ack(msg.delivery_tag)
        App.logger.debug("Handle data: done with #{msg.body_io.to_s}")
      end

      loop do
        sleep 100
      end
    end
  end
end
