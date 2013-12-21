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


puts "Joining a network"
join_msg = n.joinNetwork("8080","blueberry", "chocolate"  );
puts "Joined a network"
sleep(40)

puts "Index message sending"
unique_words = Array.new()
unique_words.push("cucumber")
join_msg = n.indexPage("www.dsg.tcd.ie", unique_words)
puts "Index message sent"
sleep(10)
#=begin=end
=begin
puts "Ping component"
msg_constructor = Message.new()
join_msg = msg_constructor.ping(n.hashString("component"),n.hashString("blueberry"),ip);
puts join_msg
s.send(join_msg, 0, 'localhost', 8080)
puts "Pinged component"
=end


sleep(5)
loop do

end


