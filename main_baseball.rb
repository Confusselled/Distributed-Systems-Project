require "./Message"
require "./Messaging"
require "./Routing"
require 'socket'
require 'json'
require './Node'

ip = "8088"




s = UDPSocket.new()
s.bind(nil, ip)

n = Node.new()
n.init(s)


puts "Joining a network"
join_msg = n.joinNetwork("8080","baseball", "component"  );
puts "Joined a network"
sleep(10)




sleep(5)

loop do

end

