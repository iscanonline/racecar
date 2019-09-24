class CatConsumer < Racecar::EventBusConsumer
  subscribes_to_stream "nonprod.eu1.rmm.entity"

  def process(message)
    puts message.value
  end
end
