require "amqp-client"

AMQP::Client.start("amqp://guest:guest@localhost") do |c|
  puts "connected..?"
  c.channel do |ch|
    q = ch.queue("my-queue")

    100000.times do |i|
      q.publish "msg-titi-toto-tutu#{i}"
      puts "wrote"
      sleep 0.001
    end
  end
end
