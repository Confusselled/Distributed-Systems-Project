require "json"

class Routing
  @routing_table = Array.new()

  def routing_table()
    @routing_table
  end


  def initialize
    @routing_table = Array.new()
  end

  def get_ip(id)
    node = Hash.new()
    node = @routing_table.detect{|n| n["node_id"]==id}
    node["ip_address"]
  end

  def add_node(id, ip)
    node = Hash.new
    node ={
        "node_id" => id,
        "ip_address"=> ip,
    }
    if !(@routing_table.include?(node))
      @routing_table.push(node)
    end
  end

  def remove_node(id)
    node = Hash.new()
    node = @routing_table.detect{|n| n["node_id"]==id}
    @routing_table.delete(node)

  end

  def add_multiple_nodes(nodes)
    @routing_table.concat(nodes)
    #remove any duplicates
    @routing_table.uniq
  end

  def get_closest_node_by_id(id)
    #puts "ID: "
    #puts id
    #puts "Routing Table:"
    #puts @routing_table
    if @routing_table.length > 0
      #puts "Best dif initial calc"
      #puts @routing_table[0]["node_id"].ord
      #puts id.ord
      best_dif = (@routing_table[0]["node_id"].ord - id.ord).abs
      curr_dif = 0
      closest_node = Hash.new()
      closest_node = @routing_table[0]
      #puts "best dif"
      #puts best_dif
      #puts "closest Node"
      #puts closest_node
      @routing_table.each{|x| curr_dif = (x["node_id"].ord - id.ord).abs
        if curr_dif < best_dif
          best_dif = curr_dif
          closest_node = x
          #puts "new closest node"
          #puts closest_node
        end
      }
      #puts closest_node
      closest_node["ip_address"]
    else
      '0'
    end
  end

  def get_ID_of_closest_node(id)
    #puts "ID: "
    #puts id
    #puts "Routing Table:"
    #puts @routing_table
    if @routing_table.length > 0
      #puts "Best dif initial calc"
      #puts @routing_table[0]["node_id"].ord
      #puts id.ord
      best_dif = (@routing_table[0]["node_id"].ord - id.ord).abs
      curr_dif = 0
      closest_node = Hash.new()
      closest_node = @routing_table[0]
      #puts "best dif"
      #puts best_dif
      #puts "closest Node"
      #puts closest_node
      @routing_table.each{|x| curr_dif = (x["node_id"].ord - id.ord).abs
      if curr_dif < best_dif
        best_dif = curr_dif
        closest_node = x
        #puts "new closest node"
        #puts closest_node
      end
      }
      #puts closest_node
      closest_node["node_id"]
    else
      '0'
    end
  end

end