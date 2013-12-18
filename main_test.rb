require "./Message"
require "./Messaging"
require "./Routing"
require 'socket'
require 'json'
require './Node'

ip = "8085"




s = UDPSocket.new()
s.bind(nil, ip)

n = Node.new()
n.init(s)

=begin
puts "Joining a network"
join_msg = n.joinNetwork("8080");
puts "Joined a network"
sleep(10)

puts "Leaving a network"
leave_msg = n.leaveNetwork("42");


sleep(5)
=end



