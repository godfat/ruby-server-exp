
require 'timeout'
require 'socket'

use Rack::ContentType
use Rack::ContentLength

OK      = [200, {}, ["OK\n"]]
HOST    = '127.0.0.1'
PORT    = 12345
LATENCY = "GET /latency HTTP/1.0\r\n\r\n"
THROUGH = "GET /through HTTP/1.0\r\n\r\n"

map '/cpu' do
  run lambda{ |env|
    work = lambda{
      begin
        timeout(0.5){ true while true }
      rescue Timeout::Error
        OK
      end
    }

    if Fiber.respond_to?(:current)
      if defined?(EM)
        f = Fiber.current
        r = nil
        EM.defer(lambda{ r = work.call }, f.method(:resume))
        Fiber.yield
        r
      else
        f = Fiber.current
        r = nil
        Thread.new{
          r = work.call
          # tell rainbows to resume us in main thread
          Rainbows::Fiber::ZZ[f] = Time.now - 1
        }
        Fiber.yield
        r
      end
    else
      work.call
    end
  }
end

class SlowApp
  def initialize get
    @get = get
    @connection = Class.new(EM::Connection){
      singleton_class.module_eval{ attr_accessor :get }
      self.get = get
      def initialize       ; @fiber, @data = Fiber.current, []; end
      def post_init        ; send_data(self.class.get)        ; end
      def unbind           ; @fiber.resume(@data)             ; end
      def receive_data data; @data << data                    ; end
      # we rely on the remote server closes the connection here
    } if defined?(EM)
  end

  def call env
    # only eventmachine + fiber spawn falls here
    if defined?(EM) && Fiber.respond_to?(:current)
      EM.connect(HOST, PORT, @connection)
      [200, {}, ["<pre>#{Fiber.yield.map(&:size).inject(&:+)}</pre>"]]
    else # eventmachine + thread should use normal socket
      sock = if defined?(FiberTCPSocket)
               FiberTCPSocket
             else
               TCPSocket
             end.new(HOST, PORT)
      begin
        sock.write(@get)
        buf = []
        sock.each{ |data|   # for FiberTCPSocket, it would call Fiber.yield
          if defined?(FiberTCPSocket)
            buf << data.dup # rainbows is reusing buf, so we dup here
          else
            buf << data
          end
        }
        [200, {}, ["<pre>#{buf.map(&:size).inject(&:+)}</pre>"]]
      ensure
        sock.close
      end
    end
  end
end

map '/latency' do
  run SlowApp.new(LATENCY)
end

map '/through' do
  run SlowApp.new(THROUGH)
end
