# Merge with price data from scryfall bulk export
class PatchScryfallPrices < Patch
  @@scryprice = nil
  def call
    @@scryprice ||= JSON.parse(File.read("all-cards.json")).map {|card| ["#{card["set"]}/#{card["collector_number"]}", card["prices"]] }.to_h
    each_printing do |card|
      next unless card["set"] and card["number"]
      prices = @@scryprice["#{card["set"]["code"]}/#{card["number"]}"] rescue nil
      card["prices"] = prices if prices
    end
  end
end
