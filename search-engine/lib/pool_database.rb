require "csv"

class PoolDatabase
  def initialize(db)
    @db = db
  end

  def resolve_card(count, set_code, card_number, card_name, foil=false, c)
    set = @db.sets[set_code.downcase.gsub(/ubt/, "puma").gsub(/jgc/, "g07")] or raise "Set not found #{set_code}"
    name = (card_name || "").gsub(/[|│]/, " // ").gsub(/’/, "'")
    names = [card_name, name, name.gsub(/ \/\/.*/, "")]
    printing = set.printings.find{|cp| cp.number == card_number || names.include?(cp.name) }
    raise "Card not found #{set_code}/#{card_number}/#{names[3]} #{c}" unless printing
    [count, PhysicalCard.for(printing, !!foil)]
  end

  def load!(path=Pathname("#{__dir__}/../../index/pool_index.json"))
    JSON.parse(path.read).each do |deck|
      listings = (deck["listings"] || []).map{|listing| CSV.read("#{__dir__}/../../index/#{listing}", col_sep: "\t") }
      cards = (deck["cards"] || []).map{|c| resolve_card(*c) }.concat(
        listings.flat_map{|listing| listing.flat_map {|c|
          [if c[4].to_i > 0 then resolve_card(c[4], c[1], nil, c[2], false, c) end,
           if c[5].to_i > 0 then resolve_card(c[5], c[1], nil, c[2], true, c) end]
        }.compact
      })
      sideboard = (deck["sideboard"] || []).map{|c| resolve_card(*c) }
      commander = (deck["commander"] || []).map{|c| resolve_card(*c) }
      display = deck["display"]
      date = deck["release_date"]
      date = date ? Date.parse(date) : nil
      deck = PreconDeck.new(
        OpenStruct.new({code: "pool", name: "pool"}),
        deck["name"],
        "Card pool",
        date,
        cards,
        sideboard,
        commander,
	display,
      )
      @db.pools << deck
    end
  end
end
