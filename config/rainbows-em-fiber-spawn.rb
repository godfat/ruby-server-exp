
require 'fiber'

worker_processes 4
timeout 30

Rainbows! do
  use :EventMachine, :em_client_class => lambda{
    RainbowsEventMachineFiberSpawnClient
  }
  if defined?(Zbatery)
    worker_connections      16*4
  else
    worker_connections      16
  end

  client_max_body_size      5*1024*1024 # 5 megabytes
  client_header_buffer_size 8*1024      # 8 kilobytes
end

after_fork{ |_, _|
  class RainbowsEventMachineFiberSpawnClient < Rainbows::EventMachine::Client
    def app_call input
      Fiber.new{ super }.resume
    end
  end
}
