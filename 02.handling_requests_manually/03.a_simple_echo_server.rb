require "socket"

server = TCPServer.new("localhost", 3003)
loop do
  client = server.accept

  client.puts "HTTP/1.1 200 OK\r\n\r\n"

  request_line = client.gets
  puts request_line

  client.puts request_line
  client.puts rand(6) + 1

  client.close
end