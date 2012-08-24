
class ThinThreadSpawnConnection < Thin::Connection
  def process
    @request.threaded = true
    Thread.new{ post_process(pre_process) }
  end
end

class ThinThreadSpawnServer < Thin::Backends::TcpServer
  def initialize host, port, _
    super(host, port)
  end

  def connect
    @signature = EM.start_server(
      @host, @port, ThinThreadSpawnConnection,
      &method(:initialize_connection))
  end
end
