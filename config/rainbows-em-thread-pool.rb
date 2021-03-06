
worker_processes 4
timeout 30

Rainbows! do
  use :EventMachine, :em_client_class => lambda{
    RainbowsEventMachineThreadPoolClient
  }
  if defined?(Zbatery)
    worker_connections      256*4
  else
    worker_connections      256
  end

  client_max_body_size      5*1024*1024 # 5 megabytes
  client_header_buffer_size 8*1024      # 8 kilobytes
end

after_fork{ |_, _|
  EM.threadpool_size = 64
  class RainbowsEventMachineThreadPoolClient < Rainbows::EventMachine::Client
    def app_call input
      set_comm_inactivity_timeout 0
      @env[RACK_INPUT] = input
      @env[REMOTE_ADDR] = @_io.kgio_addr
      @env[ASYNC_CALLBACK] = method(:write_async_response)
      @env[ASYNC_CLOSE] = EM::DefaultDeferrable.new
      @deferred = true
      EM.defer{
        status, headers, body = catch(:async) {
          APP.call(@env.merge!(RACK_DEFAULTS))
        }
        if nil == status || -1 == status
          @deferred = true
        else
          @deferred = nil
          ev_write_response(status, headers, body, @hp.next?)
        end
      }
    end
  end
}
