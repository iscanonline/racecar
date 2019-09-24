class ProducingConsumer < Racecar::EventBusConsumer
  subscribes_to_stream "messages", start_from_beginning: false

  def process(message)
    value = message.value.reverse

    produce value, topic: "reverse-messages"
  end
end
