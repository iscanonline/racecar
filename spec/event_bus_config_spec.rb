require "ostruct"
require "racecar/config"

RSpec.describe Racecar::EventBusConfig do
  let(:fake_response) do
    fake_config_response("somestream")
  end

  let(:event_bus_config) do
    conf = Racecar::EventBusConfig.new(15*60)
    conf.routes = "http://myroutes"
    allow(conf).to(receive(:load)) { |stream| fake_config_response(stream) }
    conf
  end

  it "loads config for a stream" do
    allow(event_bus_config).to(receive(:load)) { |stream| fake_config_response(stream) }
    event_bus_config.stream = "stream1"
    event_bus_config.reload!
    expect(event_bus_config.brokers).to eq ["cluster.url.stream1-0", "cluster.url.stream1-1", "cluster.url.stream1-2"]
    expect(event_bus_config.topic).to eq "msp.stream1"
    expect(event_bus_config).to(have_received(:load).with("stream1"))
  end

  it "loads config only once" do
    event_bus_config.stream = "stream1"
    cnt = 0
    event_bus_config.on_reload { cnt = cnt + 1 }
    event_bus_config.reload!
    event_bus_config.reload!
    expect(cnt).to eq 1
  end

  it "reloads config when stream changes" do
    event_bus_config.stream = "stream1"
    cnt = 0
    event_bus_config.on_reload { cnt = cnt + 1 }
    event_bus_config.reload!
    event_bus_config.stream = "stream2"
    event_bus_config.reload!
    expect(cnt).to eq 2
  end

  it "reloads config when is reset" do
    fake_response = fake_config_response("stream1")
    allow(event_bus_config).to(receive(:load)).and_return fake_response

    event_bus_config.stream = "stream1"
    cnt = 0
    event_bus_config.on_reload { cnt = cnt + 1 }
    event_bus_config.reload!
    event_bus_config.reset!
    fake_response[:clusters][0][:conExternal] = ["updated"]
    event_bus_config.reload!
    expect(cnt).to eq 2
  end

  it "re-downloads config when force, but does not trigger #on_reload unless actually updated" do
    fake_response = fake_config_response("stream1")
    allow(event_bus_config).to(receive(:load)).and_return fake_response

    event_bus_config.stream = "stream1"
    cnt = 0
    event_bus_config.on_reload { cnt = cnt + 1 }
    event_bus_config.reload!

    event_bus_config.reload!(true)
    expect(cnt).to eq 1

    fake_response[:clusters][0][:conExternal] = ["updated"]
    event_bus_config.reload!(true)
    expect(cnt).to eq 2

    event_bus_config.reload!(true)
    expect(cnt).to eq 2

    fake_response[:consumer][0][:topic] = "updated"
    event_bus_config.reload!(true)
    expect(cnt).to eq 3
  end

  it "raises exceptions on config data with no or invalid consumer section" do
    fake_response = fake_config_response("stream1")
    allow(event_bus_config).to(receive(:load)).and_return fake_response

    event_bus_config.stream = "stream1"
    fake_response[:consumer].each {|c| c[:status] = "history"}
    expect { event_bus_config.reload! }.to raise_exception("No active consumer")

    event_bus_config.reset!
    fake_response[:consumer] = []
    expect { event_bus_config.reload! }.to raise_exception("No active consumer")

    event_bus_config.reset!
    fake_response[:consumer] = nil
    expect { event_bus_config.reload! }.to raise_exception("No active consumer")
  end

  it "raises exceptions on config data with no or invalid cluster section" do
    fake_response = fake_config_response("stream1")
    allow(event_bus_config).to(receive(:load)).and_return fake_response

    event_bus_config.stream = "stream1"
    fake_response[:clusters].each {|c| c[:uid] = "invalid"}
    expect { event_bus_config.reload! }.to raise_exception(/Invalid cluster uid/)

    event_bus_config.reset!
    fake_response[:clusters] = []
    expect { event_bus_config.reload! }.to raise_exception(/Invalid cluster uid/)

    event_bus_config.reset!
    fake_response[:clusters] = nil
    expect { event_bus_config.reload! }.to raise_exception(/Invalid cluster uid/)
  end

end
