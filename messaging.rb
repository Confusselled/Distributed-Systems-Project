class Messaging

  def message_receiver(s)
    loop do
      #receive a message
      t, sender = s.recvfrom(1000)
      text = JSON.parse(t)

      #Identify the message type and
      #handle it appropriately
      case text["type"]
        when "JOINING_NETWORK"
          puts "Received a JOINING_NETWORK message"


        when "JOINING_NETWORK_RELAY"
          puts "Received a JOINING_NETWORK_RELAY message"
        when "ROUTING_INFO"
          puts "Received a ROUTING_INFO message"
        when "LEAVING_NETWORK"
          puts "Received a LEAVING_NETWORK message"
        when "INDEX"
          puts "Received a INDEX message"
        when "SEARCH"
          puts "Received a SEARCH message"
        when "SEARCH_RESPONSE"
          puts "Received a SEARCH_RESPONSE message"
        when "PING"
          puts "Received a PING message"
        when "ACK"
          puts "Received a ACK message"
        else
          puts "Received an unrecognised message type"

      end
    end
  end


end