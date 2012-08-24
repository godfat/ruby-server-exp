
require 'fiber'

class ThinFiberSpawnConnection < Thin::Connection
  def process
    @request.threaded = false
    Fiber.new{ post_process(pre_process) }.resume
  end
end

class ThinFiberSpawnServer < Thin::Backends::TcpServer
  def initialize host, port, _
    super(host, port)
  end

  def connect
    @signature = EM.start_server(
      @host, @port, ThinFiberSpawnConnection,
      &method(:initialize_connection))
  end
end
