require 'json'
require "open-uri"

module Racecar
  class EventBusConfig
    attr_accessor :routes, :brokers, :stream, :topic, :cluster_uid

    def initialize(cache_timeout)
      @reload_handler = proc {}
      @cache_timeout = 15 * 60
      reset!
    end

    def stream=(stream)
      if stream != @stream
        @stream = stream
        reset!
      end
    end

    def reset!
      @last_reload = Time.at(0)
      self.brokers = []
      self.topic = nil
    end

    def on_reload(&handler)
      @reload_handler = handler
    end

    def load(stream)
      url = "#{routes}/status/stream_route_#{stream}.json"
      open(url) do |f|
        body = f.read
        JSON.parse(body, symbolize_names: true)
      end
    rescue => e
      raise "Unable to load configuration for stream #{stream} from #{url}: ", e
    end

    def reload!(force_download=false)
      return false if @last_reload >= (Time.now - @cache_timeout) and !force_download
      @last_reload = Time.now

      config = load(self.stream)
      consumer = get_active_consumer(config)
      raise "No active consumer" unless consumer
      cluster = get_cluster(config, consumer[:cluster_uid])
      raise "Invalid cluster uid for #{consumer}" unless cluster

      return false if self.brokers == cluster[:conExternal] \
          and self.topic == consumer[:topic] \
          and self.cluster_uid == consumer[:cluster_uid]

      self.cluster_uid = consumer[:cluster_uid]
      self.brokers = cluster[:conExternal]
      self.topic = consumer[:topic]

      @reload_handler.call(self)
      true
    end

    private

    def get_active_consumer(config)
      return nil if config == nil or config[:consumer] == nil
      config[:consumer].find{|c| c[:status] == "active"}
    end

    def get_cluster(config, uid)
      return nil if config == nil or config[:clusters] == nil
      config[:clusters].find{|c| c[:uid] == uid}
    end
  end
end
