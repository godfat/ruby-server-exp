
worker_processes 4
timeout 30

Rainbows! do
  use :FiberSpawn
  if defined?(Zbatery)
    worker_connections      16*4
  else
    worker_connections      16
  end

  client_max_body_size      5*1024*1024 # 5 megabytes
  client_header_buffer_size 8*1024      # 8 kilobytes
end

class ::FiberTCPSocket < Kgio::TCPSocket
  include Rainbows::Fiber::IO::Methods
end
