
require 'eio'

EIO.open(__FILE__) do |fd|
  puts "Opend"
  EIO.read(fd) do |source|
    p source
    puts "Read"
  end
end

io = IO.new(EIO.fd)
while EIO.requests > 0
  select([io])
  EIO.poll
end
puts "Done"
