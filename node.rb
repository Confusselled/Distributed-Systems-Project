require "./Message"
require "./Messaging"
require "./Routing"
require "./Index"
require 'optparse'
require 'Time'

class Node
  @id
  @routing_info
  @msg_server
  @msg_constructor
  @bootstrap
  @socket
  @IP
  @index
  @options
  @search_resuts
  @index_ack_waitinglist
  @ping_ack_waitinglist


  def message_receiver
    loop do
      #receive a message
      puts "Waiting for messages"
      t, sender = @socket.recvfrom(1000)
      text = JSON.parse(t)
      #puts text
      #Identify the message type and
      #handle it appropriately
      case text["type"]
        when "JOINING_NETWORK"
          puts "Received a JOINING_NETWORK message"
          self_id = Hash.new()
          self_id = {
              "node_id" => @id,
              "ip_address" => @IP
          }
          routing_i = Array.new()
          routing_i.concat(@routing_info.routing_table())
          routing_i.push(self_id)
          #Construct and send response
          msg = @msg_constructor.routing_info(@id,text["node_id"], @IP, routing_i )
          @socket.send(msg, 0, '127.0.0.1', text["ip_address"])
          #extract node info and add to routing table
          @routing_info.add_node(text["node_id"], text["ip_address"])

          #forward message to target node
          if text["target_id"] != @id
            msg = @msg_constructor.joining_network_relay(text["node_id"], text["target_id"], @id)
            @socket.send(msg, 0, '127.0.0.1', @routing_info.get_closest_node_by_id(text["target_id"]))
          end
        when "JOINING_NETWORK_RELAY"
          puts "Received a JOINING_NETWORK_RELAY message"
          self_id = Hash.new()
          self_id = {
              "node_id" => @id,
              "ip_address" => @IP
          }
          routing_i = Array.new()
          routing_i.concat(@routing_info.routing_table())
          routing_i.push(self_id)
          msg = @msg_constructor.routing_info(text["gateway_id"],text["node_id"], @IP, routing_i )
          @socket.send(msg, 0, '127.0.0.1', @routing_info.get_closest_node_by_id(text["gateway_id"]))
        when "ROUTING_INFO"
          puts "Received a ROUTING_INFO message"
          #if message is for us, extract routing
          #table info and add to our table
          if text["node_id"] == @id
            #we are the joining node, add info to our routing table
            @routing_info.add_multiple_nodes(text["route_table"])
          else
            #we are the gateway node, pass message on to joining node
            @socket.send(t, 0, '127.0.0.1', @routing_info.get_ip(text["node_id"]))
          end

        when "LEAVING_NETWORK"
          puts "Received a LEAVING_NETWORK message"
          @routing_info.remove_node(text["node_id"])

        when "INDEX"
          puts "Received a INDEX message"
          #puts text
          if text["target_id"] == @id
            @index.addIndex(text["keyword"], text["link"])
            #send ACK to original node
            mesg = @msg_constructor.ack_index(text["sender_id"], text["keyword"] )
            puts mesg
            @socket.send(mesg, 0, '127.0.0.1', @routing_info.get_closest_node_by_id(text["sender_id"]))
          else
            #puts "forwarding INDEX to:"
            @socket.send(t, 0, '127.0.0.1', @routing_info.get_closest_node_by_id(text["target_id"]))
          end

        when "SEARCH"
          puts "Received a SEARCH message"
          if text["node_id"] == @id
            mesg = @msg_constructor.search_response(text["word"], text["sender_id"], @id, @index.getIndex(text["word"]))
            #puts mesg
            #puts @routing_info.get_closest_node_by_id(text["sender_id"])
            @socket.send(mesg, 0, '127.0.0.1', @routing_info.get_closest_node_by_id(text["sender_id"]))
          else
            @socket.send(t, 0, '127.0.0.1', @routing_info.get_closest_node_by_id(text["node_id"]))
          end

        when "SEARCH_RESPONSE"
          puts "Received a SEARCH_RESPONSE message"
          #puts text
          if text["node_id"] == @id

            @search_resuts.push( text["response"] )
          else
            @socket.send(t, 0, '127.0.0.1', @routing_info.get_closest_node_by_id(text["node_id"]))
          end
        when "PING"
          puts "Received a PING message"
          puts text
          #acknowledge the PING
          mesg = @msg_constructor.ack(text["target_id"], @IP)
          puts mesg
          @socket.send(mesg, 0, '127.0.0.1', text["ip_address"])

          if text["target_id"] != @id
            ping_forward = @msg_constructor.ping(text["target_id"], text["sender_id"], @IP)
            puts "sending ping to #{@routing_info.get_closest_node_by_id(text["target_id"])}"
            closest_node = @routing_info.get_closest_node_by_id(text["target_id"])
            @socket.send(ping_forward, 0, '127.0.0.1', @routing_info.get_closest_node_by_id(text["target_id"]))
            #add to waiting list for timeout handling
            ping_list = Hash.new()
            ping_list = {
                "node_id" => text["target_id"],
                "send_time" => Time.now.to_i.to_s,
                "closest_node" => closest_node
            }
            @ping_ack_waitinglist.push(ping_list)
          else
            puts "im the ping target"
          end

        when "ACK"
          puts "Received a ACK message"
          puts text
          #puts @id
          forward = true
          @ping_ack_waitinglist.each{|x|
            if x["node_id"] == text["node_id"]
              puts "Ping poping x: #{x}"
              puts @ping_ack_waitinglist
              @ping_ack_waitinglist.delete(x)
              puts @ping_ack_waitinglist
              forward = false
            end
          }
          if forward
            #forward to target node
            mesg = @msg_constructor.ack(text["node_id"], @IP )
            puts mesg
            #puts @routing_info.get_closest_node_by_id(text["node_id"])
            @socket.send(mesg, 0, '127.0.0.1', @routing_info.get_closest_node_by_id(text["node_id"]))
          end

        when "ACK_INDEX"
          puts "Received a ACK_INDEX message"
          puts text
          puts @index_ack_waitinglist
          forward = true
          @index_ack_waitinglist.each{|x|
            if x["keyword"] == text["keyword"]
              puts "Index poping x: #{x}"
              puts @index_ack_waitinglist
              @index_ack_waitinglist.delete(x)
              puts @index_ack_waitinglist
              forward = false
            end
          }
          if forward
            #forward to target node
            #mesg = @msg_constructor.ack_index(text["node_id"], @IP )
            #puts "ACK_INDEX #{mesg}"
            #puts @routing_info.get_closest_node_by_id(text["node_id"])
            puts "forwarding the ACK_INDEX"
            puts @routing_info.get_closest_node_by_id(text["node_id"])
            @socket.send(t, 0, '127.0.0.1', @routing_info.get_closest_node_by_id(text["node_id"]))
            puts "ACK_INDEX sent"
          end

        else
          puts "Received an unrecognised message type"

      end
    end
  end




  def init(s)

    @options = {
        "boot" => false,
        "id" => 0,
        "bs_id" => 0
    }
    OptionParser.new do |opts|
      opts.on("--boot [id]") do |b|

        @options["boot"] = true
        @options["id"] = b

      end

      opts.on("--bootstrap [ip]") do |bs|
        @options["bs_id"] = bs
      end
      opts.on("--id [id]") do |id|
        @options["id"] = id
      end
      opts.on("--ip [id]") do |b|
        @IP = b
      end

    end.parse!

    @index_ack_waitinglist = Array.new
    @ping_ack_waitinglist = Array.new
    @socket = s
    @routing_info = Routing.new()
    @msg_constructor = Message.new()
    if @options["boot"] == true
      @bootstrap = true
    end
    @search_resuts = Array.new()
    @id = hashString(@options["id"])
    @msg_server = Messaging.new()
    #@IP = ip
    @index = Index.new()

    if @bootstrap
      server_thread = Thread.new{message_receiver()}
    end
    ping_mon = Thread.new{ping_monitor()}
    index_mon = Thread.new{index_monitor()}
  end

  def joinNetwork(ip, id, target_id)
    if !@bootstrap
      server_thread = Thread.new{message_receiver()}
    end
    @id = hashString(id)
    join_msg = @msg_constructor.joining_network( @id, hashString(target_id), @IP )
    @socket.send(join_msg, 0, '127.0.0.1', ip)

  end

  def leaveNetwork(net_id)
    leaving_msg = @msg_constructor.leaving_network(@id)
    @routing_info.routing_table().each{ |x| @socket.send(leaving_msg, 0, '127.0.0.1', x["ip_address"])}
    @socket.close()

  end

  def indexPage(url, unique_words)
    delta = 0
    unique_words.each { |x|
      my_mesg = @msg_constructor.index( hashString(x), @id, x, url)
      #puts my_mesg
      #puts @routing_info.get_closest_node_by_id(x)

      @socket.send(my_mesg, 0, 'localhost', @routing_info.get_closest_node_by_id(hashString(x)))

      #wait for index to be ACKed

      index_ref = Hash.new()
      index_ref = {
          "keyword" => x,
          "send_time" => Time.now.to_i.to_s
      }
      puts index_ref
      @index_ack_waitinglist.push(index_ref)
    }
  end

  def hashString(string)
    string_id = String.new(string)
    string_id = string
    hash = 0
    string_id.each_char{|x| hash = ((hash*31)+x.ord)}
    hash
  end

  def search(words)
    @search_resuts.clear
    words.each { |x|
      msg = @msg_constructor.search(x, @routing_info.get_ID_of_closest_node(hashString(x)), @id)
      #puts msg
      @socket.send(msg, 0, 'localhost', @routing_info.get_closest_node_by_id(hashString(x)))

    }
    #wait until the results are back
    while @search_resuts.length != words.length
      #puts "waiting for results"
      #puts @search_resuts
    end
    #puts @search_resuts
    #@search_resuts
  end

  def ping_monitor
    loop do
      if @ping_ack_waitinglist.length > 0
        puts "Ping waiting list > 0 and is #{@ping_ack_waitinglist}"
        @ping_ack_waitinglist.each {|x|
          if Time.now.to_i - x["send_time"].to_i >= 10
            #timer expired, remove node from routing table
            #not it is node closest to the ID we remove as
            #this is who the message was sent to, and its this
            #node that failed to respond
            puts "Ping timer expired removing node"
            @routing_info.remove_node(x["closest_node"])
            #remove node from the ping_ack_waitinglist
            @ping_ack_waitinglist.pop(x)
          end
        }
      end
      sleep(1)
    end
  end

  def index_monitor
    loop do
      #puts "looping"
      if @index_ack_waitinglist.length > 0
        puts "We are waiting for an index ACK"

        @index_ack_waitinglist.each{ |x|
          puts x
          delta = Time.now.to_i - x["send_time"].to_i
          puts delta
          if delta >= 10
            #send ping
            puts  "delta > 30"

            ping_msg = @msg_constructor.ping(hashString(x["keyword"]), @id, @IP)
            puts ping_msg
            closest_node = @routing_info.get_closest_node_by_id(hashString(x["keyword"]))
            @socket.send(ping_msg, 0, 'localhost', closest_node)
            #remove from index_ack_waitinglist and add to
            #ping_ack_waitinglist
            ping_list = Hash.new()
            ping_list = {
                "node_id" => hashString(x["keyword"]),
                "send_time" => Time.now.to_i.to_s,
                "closest_node" => closest_node
            }
            @ping_ack_waitinglist.push(ping_list)
            @index_ack_waitinglist.pop(x)
          end
          puts "exit if"
        }
      end
      sleep(1)
    end
  end

end