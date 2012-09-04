#!/usr/bin/env ruby

require 'eventmachine'

HOST = '127.0.0.1'
PORT = 12345
OK   = "HTTP/1.0 200 OK\r\n\r\n"

EM.run{
  EM.start_server(HOST, PORT, Class.new(EM::Connection){
    def receive_data data
      return if @done
      @done = true

      case data
      when /latency/
        data = OK.chars.to_a
        work = lambda{
          if d = data.shift
            send_data(d)
            EM.add_timer(50/1000.0, &work)
          else
            close_connection(true)
          end
        }
        EM.add_timer(50/1000.0, &work)

      when /through/
        send_data(OK)
        tick = 0
        sock = File.open('/dev/zero')
        work = lambda{
          if tick < 4
            send_data(sock.readpartial(1024*1024))
            tick += 1
            EM.next_tick(&work)
          else
            sock.close
            close_connection(true)
          end
        }
        EM.next_tick(&work)
      else
        send_data("what's this?")
        close_connection(true)
      end
    end
  })
}
