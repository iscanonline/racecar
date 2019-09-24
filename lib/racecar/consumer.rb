module Racecar
  class EventBusConsumer
    Subscription = Struct.new(:stream, :topic, :start_from_beginning, :max_bytes_per_partition)

    class << self
      attr_accessor :max_wait_time
      attr_accessor :group_id
      attr_accessor :offset_retention_time
      attr_accessor :subscription

      # Adds one stream subscription.
      #
      # @param stream [String] stream to subscribe to.
      # @param start_from_beginning [Boolean] whether to start from the beginning or the end
      #   of each partition.
      # @param max_bytes_per_partition [Integer] the maximum number of bytes to fetch from
      #   each partition at a time.
      # @return [nil]
      def subscribes_to_stream(stream, start_from_beginning: true, max_bytes_per_partition: 1048576)
        @subscription = Subscription.new(stream, nil, start_from_beginning, max_bytes_per_partition)
      end
    end

    def configure(consumer:, producer:)
      @_consumer = consumer
      @_producer = producer
    end

    def teardown; end

    protected

    def heartbeat
      @_consumer.trigger_heartbeat
    end

    # def produce(value, stream:, **options)
    #   @_producer.produce(value, stream, **options)
    # end
  end
end
