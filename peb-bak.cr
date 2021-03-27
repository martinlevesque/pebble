require "amqp-client"
require "kemal"
require "uuid"
require "json"
require "./handle_data"
require "./app"

App.logger.info("Starting pebble")

rabbit_cli = AMQP::Client.new("amqp://guest:guest@localhost")
rabbit_conn = rabbit_cli.connect

nb_concurrent = 0

def handle_mutation(connection, query, nb_concurrent)
  q_name = "event-queue-#{UUID.random}"
  result = nil
  App.logger.debug("Starting mutation #{query}")

  connection.channel do |ch|
    begin
      puts "current nb_concurrent = #{nb_concurrent}"

      result_if_pending = {"result": "pending", "msg": "Operation in progress"}
      return result_if_pending if nb_concurrent > 10

      # event queue creation
      event_q = ch.queue(q_name, durable = false, auto_delete = true)

      # forward
      main_queue = ch.queue("my-queue")
      main_queue.publish("{\"event\": \"#{q_name}\", \"query\": \"#{query}\"}")

      got_response = nil
      started_at = Time.utc

      event_q.subscribe(no_ack: false) do |msg|
        got_response = msg.body_io.to_s
      end

      loop do
        App.logger.debug("Waiting response mutation #{q_name}")
        break if got_response
        sleep 0.10
      end

      App.logger.debug("Got response mutation #{q_name}")
      result = got_response
    rescue ex
      App.logger.error("Issue #{ex.message}")
      result = {"result": "error", "msg": ex.message}
    ensure
      App.logger.debug("Cleaning for mutation #{q_name}")
      event_q = ch.queue(q_name, durable = false, auto_delete = true)
      event_q.delete
      App.logger.debug("Done with mutation #{q_name}")
    end
  end

  result
end

post "/query" do |env|
  query_type = env.params.json["type"]
  query = env.params.json["query"]

  # query = "INSERT INTO contacts(name, age) VALUES(\"wong\", 16)"

  nb_concurrent += 1
  result = handle_mutation(rabbit_conn, query, nb_concurrent)
  nb_concurrent -= 1

  puts "result is #{result}, nb_concurrent = #{nb_concurrent}"

  result
end

Kemal.run
