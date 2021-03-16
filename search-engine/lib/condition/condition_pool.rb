class ConditionPool < Condition
    def initialize(pool_name)
      @pool_name = pool_name.downcase.gsub(/\s|-|_/, "")
    end
  
    def search(db)
      print "pool: '#{@pool_name}'"
      db.pools.find {|x| x.name.downcase.gsub(/\s|-|_/, "") == @pool_name}.cards.flat_map(&:last).flat_map(&:parts).to_set
    end
  
    def metadata!(key, value)
      super
      @time = value if key == :time
    end
  
    def to_s
      timify_to_s "pool:#{maybe_quote(@pool_name)}"
    end
  end
  