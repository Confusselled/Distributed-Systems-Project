class Index
  @Indexes


  def initialize
    @Indexes = Hash.new()

  end

  def addIndex(keyword, url)
    puts "Index before"
    puts @Indexes
    if @Indexes.include?(keyword)
      #puts "keyword found"
      #check if url is already present
      if @Indexes[keyword].any?{|h| h["url"] == url}
        #puts "url found"
        #increase rank by 1
        @Indexes[keyword].each{|x| puts x
            if x["url"] == url
              x["rank"] = x["rank"].ord + 1
            end
        }
      else
        #puts "url not found"
        #url not associated with that keyword, add it
        x = Hash.new()
        x = {
            "url" => url,
            "rank" => 1
        }
        @Indexes[keyword].push(x)
      end
    else
      x = Hash.new()
      x = {
          "url" => url,
          "rank" => 1
      }
      a = Array.new()
      a.push(x)
      @Indexes = {
          keyword => a
      }
    end
    puts "Index after"
    puts @Indexes
  end

  def getIndex(keyword)
    @Indexes[keyword]
  end

end