# Just for sets with boosters, some cards will be non-booster
# That's planeswalker deck exclusive cards,
# and also Firesong and Sunspeaker buy-a-box promo

class PatchExcludeFromBoosters < Patch
  def call
    each_printing do |card|
      set_code = card["set_code"]

      if sets_without_basics_in_boosters.include?(set_code) and card["supertypes"]&.include?("Basic")
        card["exclude_from_boosters"] = true
      end

      if exclude_from_boosters(set_code, card["number"])
        card["exclude_from_boosters"] = true
      end

      # They only have full art promos in boosters
      # Non full art are for precons
      #
      # in v4 non-booster version got -a suffix
      if %W[bfz ogw].include?(set_code) and
        card["supertypes"] == ["Basic"] and
        card["number"] =~ /a/
        card["exclude_from_boosters"] = true
      end

      # WAR are Japanese alt arts are in boosters,
      # just not in English boosters, so count them out
      #
      # Other star cards are foil alt arts and in boosters
      if card["number"] =~ /★/ and set_code == "war"
        card["exclude_from_boosters"] = true
      end

      # Mostly misprints and such
      if card["number"] =~ /†/ and (set_code != "arn" and set_code != "shm")
        card["exclude_from_boosters"] = true
      end

      # Mostly Chinese non-skeleton versions
      if card["number"] =~ /s/i and ["por", "usg", "inv", "pcy", "5ed", "6ed", "7ed", "8ed", "9ed"].include?(set_code)
        card["exclude_from_boosters"] = true
      end
    end
  end

  # Based on http://www.lethe.xyz/mtg/collation/index.html
  # These sets do not have foils
  #
  # Many other sets had foil basics in boosters
  # but nonfoil basics only in other products
  # These do not belong here
  def sets_without_basics_in_boosters
    ["ice", "mir", "tmp", "usg", "4ed", "5ed", "6ed"]
  end

  def exclude_from_boosters(set_code, number)
    number_i = number.to_i
    set = set_by_code(set_code)
    base_size = set["base_set_size"]
    # Not correct for all sets:
    # https://github.com/mtgjson/mtgjson/issues/765

    case set_code
    when "2xm",
      "aer",
      "akh",
      "akr",
      "cmr",
      "dom",
      "eld",
      "grn",
      "hou",
      "kld",
      "klr",
      "m15",
      "m19",
      "m20",
      "mh1",
      "ori",
      "rix",
      "rna",
      "thb",
      "war",
      "xln",
      "znr",
      "khm",
      "tsr"
      # no weird cards in boosters and we can rely on mtgjson data
      number_i > base_size
    when "mh2"
      # incorrect in mtgjson
      number_i > 303
    when "stx"
      # incorrect in mtgjson
      number_i > 275
    when "afr"
      number_i > 281 or number =~ /★/
    when "sta"
      # incorrect in mtgjson
      number_i > 63 or number =~ /e/
    when "m21"
      # showcase basics actually in boosters
      number_i > base_size and not (309..313).include?(number_i)
    when "iko"
      # borderless planeswalkers are numbered #276-278
      # showcase cards are numbered #279-313
      # extended artwork cards are numbered #314-363 - these are just collector boosters
      ![1..274, 276..278, 279..313].any?{|r| r.include?(number_i)}
    else
      false
    end
  end
end
