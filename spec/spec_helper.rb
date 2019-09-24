$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "racecar"

RSpec.configure do |config|
  config.disable_monkey_patching!
end

def fake_config_response(stream)
  {
      updated: Time.now.to_f,
      clusters: [
          {
              uid: "cluster.uid.#{stream}",
              name: "cluster.name.#{stream}",
              conExternal: %W(cluster.url.#{stream}-0 cluster.url.#{stream}-1 cluster.url.#{stream}-2)
          }
      ],
      producer: {
          cluster_uid: "cluster.uid.#{stream}",
          status: "active",
          topic: "msp.#{stream}"
      },
      consumer: [
          {
              cluster_uid: "cluster.uid.#{stream}",
              status: "active",
              topic: "msp.#{stream}"
          },
          {
              cluster_uid: "cluster.uid.#{stream}.history",
              status: "history",
              topic: "msp.#{stream}"
          }
      ]
  }
end