
require 'socket'

class Reactor
  def run
    until read_socks.empty? && write_socks.empty?
      rs, ws = IO.select(read_socks, write_socks, [], 0.05)
      read_data(rs)  if rs
      write_data(ws) if ws
    end
  end
  def read sock, &callback
    read_socks << sock
    read_calls[sock.object_id] = callback
  end
  def write sock, data, &callback
    write_socks << sock
    write_pairs[sock.object_id] = [data, callback]
  end
  private
  def read_socks ; @read_socks  ||= []; end
  def read_calls ; @read_calls  ||= {}; end
  def write_socks; @write_socks ||= []; end
  def write_pairs; @write_pairs ||= {}; end
  def read_data rs
    rs.each{ |r|
      begin
        read_calls[r.object_id].call(r.read_nonblock(8192))
      rescue Errno::EAGAIN, ::IO::WaitReadable
      rescue Errno::ECONNRESET, EOFError
        read_socks.delete(r)
      end
    }
  end
  def write_data ws
    ws.each{ |w|
      data, callback = write_pairs[w.object_id]
      begin
        data.slice!(0, w.write_nonblock(data))
        raise EOFError if data.empty?
      rescue ::IO::WaitWritable
      rescue EOFError
        write_pairs.delete(w.object_id)
        write_socks.delete(w)
        callback.call(w)
      end
    }
  end
end

reactor = Reactor.new
reactor.write TCPSocket.new('example.com', 80), "GET / HTTP/1.0\r\n\r\n" do |sock|
  reactor.read sock do |response|
    print response
  end
end
reactor.run
puts
