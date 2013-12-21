require "./Message"
require "./Messaging"
require "./Routing"
require 'socket'
require 'json'
require './Node'

ip = "8086"




s = UDPSocket.new()
s.bind(nil, ip)

n = Node.new()
n.init(s)


puts "Joining a network"
join_msg = n.joinNetwork("8080","cucumber", "blueberry"  );
puts "Joined a network"
sleep(15)


puts "Index message sending"
unique_words = Array.new()
unique_words.push("blueberry")
#unique_words.push("chocolate")
join_msg = n.indexPage("www.dsg.tcd.ie", unique_words)
puts "Index message sent"
sleep(10)

=begin
puts "Index message sending"
unique_words = Array.new()
unique_words.push("blueberry")
join_msg = n.indexPage("www.berries.ie", unique_words)
puts "Index message sent"
sleep(10)
=end


sleep(5)

loop do

end

