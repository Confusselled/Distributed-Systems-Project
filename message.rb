require 'json'
class Message
  def joining_network( node_id, target_id, ip )
    message = Hash.new
    message ={
      "type" => "JOINING_NETWORK",
      "node_id"=> node_id,
      "target_id" => target_id,
      "ip_address" => ip
    }
    return message.to_json
  end

  def joining_network_relay( node_id, target_id, gateway_id)
    message = Hash.new
    message = {
        "type" => "JOINING_NETWORK_RELAY",
        "node_id" => node_id,
        "target_id" => target_id,
        "gateway_id" => gateway_id
    }
    return message.to_json
  end

  def routing_info( gateway_id, node_id, ip , r_table)
    message = Hash.new
    message = {
        "type" => "ROUTING_INFO",
        "gateway_id" => gateway_id,
        "node_id" => node_id,
        "ip_address" => ip,
        "route_table" => r_table
    }
    return message.to_json
  end

  def leaving_network( node_id)
    message = Hash.new
    message = {
        "type" => "LEAVING_NETWORK",
        "node_id" => node_id
    }
    return message.to_json
  end

  def index( target_id, sender_id, keyword, links)
    message = Hash.new
    message = {
        "type" => "INDEX",
        "target_id" => target_id,
        "sender_id" => sender_id,
        "keyword" => keyword,
        "link" => links
    }
    return message.to_json
  end

  def search( word, node_id, sender_id)
    message = Hash.new
    message = {
        "type" => "SEARCH",
        "word" => word,
        "node_id" => node_id,
        "sender_id" => sender_id,
    }
    return message.to_json
  end

  def search_response( word, node_id, sender_id, response)
    message = Hash.new
    message = {
        "type" => "SEARCH_RESPONSE",
        "word" => word,
        "node_id" => node_id,
        "sender_id" => sender_id,
        "response" => response
    }
    return message.to_json
  end

  def ping( target_id, sender_id, ip)
    message = Hash.new
    message = {
        "type" => "PING",
        "target_id" => target_id,
        "sender_id" => sender_id,
        "ip_address" => ip
    }
    return message.to_json
  end

  def ack(node_id, ip)
    message = Hash.new
    message = {
        "type" => "ACK",
        "node_id" => node_id,
        "ip_address" => ip
    }
    return message.to_json
  end

end