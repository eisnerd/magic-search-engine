# Merge with price data from scryfall bulk export

require 'fast_jsonparser'
class PatchScryfallPrices < Patch
  @@scryprice = nil
  def call
    unless @@scryprice
      @@scryprice = {}
      FastJsonparser.load_many("all-cards-prices.json") { |card| prices = @@scryprice["#{card[:set]}/#{card[:collector_number]}"] ||= {}; prices.merge!(card[:prices].compact) }
    end
    each_printing do |card|
      next unless card["set"] and card["number"]
      prices = @@scryprice["#{card["set"]["code"]}/#{card["number"]}"] rescue nil
      card["prices"] = prices if prices
    end
  end
end
