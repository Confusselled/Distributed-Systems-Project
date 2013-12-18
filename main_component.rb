require "./Message"
require "./Messaging"
require "./Routing"
require 'socket'
require 'json'
require './Node'

ip = "8087"




s = UDPSocket.new()
s.bind(nil, ip)

n = Node.new()
n.init(s)


puts "Joining a network"
join_msg = n.joinNetwork("8080","component", "cucumber"  );
puts "Joined a network"
sleep(10)

puts "Searching for Blueberries"
words = Array.new()
words.push("blueberry")
join_msg = n.search( words );
puts "search results:"
puts join_msg
sleep(10)





sleep(5)

loop do

end

