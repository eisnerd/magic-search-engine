# This class represents card from index point of view, not from data point of view
# (thinking in solr/lucene terms)
require "date"

class Card
  attr_reader :data
  def initialize(data)
    @data = data
  end

  def name
    @data["name"].gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü", "Aaaaaeeeioouuu")
  end

  def colors
    (@data["colors"] || []).map{|c| color_codes.fetch(c)}
  end

  def timeshifted
    @data["timeshifted"] || false
  end

  def mana_cost
    @data["manaCost"] ? @data["manaCost"].downcase : nil
  end

  def watermark
    if @data["watermark"]
      @data["watermark"].downcase
    else
      nil
    end
  end

  def release_date
    case @data["releaseDate"]
    when /\A\d{4}-\d{2}\z/
      # ...
      "#{@data["releaseDate"]}-01"
    else
      @data["releaseDate"]
    end
  end

  def year
    Date.parse(release_date).year
  end

  def color_identity
    ci = colors.dup
    text.scan(/{(.*?)}/).each do |sym,|
      case sym.downcase
      when /\A(\d+|[½∞txyzsqp])\z/
        # 12xyz - colorless
        # ½∞ - unset colorless
        # t - tap
        # q - untap
        # s - snow
        # p - generic Phyrexian mana (like on Rage Extractor text)
      when /\A([wubrg])\z/
        ci << $1
      when /\A([wubrg])\/p\z/
        # Phyrexian mana
        ci << $1
      when /\Ah([wubrg])\z/
        # Unset half colored mana
        ci << $1
      when /\A2\/([wubrg])\z/
        ci << $1
      when /\A([wubrg])\/([wubrg])\z/
        ci << $1 << $2
      else
        warn sym
        require 'pry'; binding.pry
      end
    end
    ci.uniq
  end

  def frame
    # Each promo needs to be manually checked
    old_border_sets = %w"al be an un ced cedi drc aq rv lg dk mbp fe dcilm 4e ia ch hl ai arena uqc mr mgbc itp vi 5e pot po wl ptc tp sh po2 jr ex ug apac us at ul 6e p3k ud st guru wrl wotc mm br sus fnmp euro ne st2k pr bd in ps 7e mprp ap od dm tr ju on le sc rep tsts"

    if timeshifted and set_code == "fut"
      "future"
    elsif old_border_sets.include?(set_code)
      "old"
    else
      "new"
    end
  end

  def types
    ["types", "subtypes", "supertypes"].map{|t| @data[t] || []}.flatten.map(&:downcase)
  end

  def rarity
    r = @data["rarity"].downcase
    return "mythic" if r == "mythic rare"
    r
  end

  def legality(format)
    format = format.downcase
    format = "commander" if format == "edh"
    leg = @data["legalities"].find{|leg| leg["format"].downcase == format}
    if leg
      leg["legality"].downcase
    else
      nil
    end
  end

  def artist
    @data["artist"].downcase
  end

  def cmc
    @data["cmc"] || 0
  end

  # Normalize unicode, remove remainder text
  def text
    text = (@data["text"] || "").gsub("Æ", "Ae").tr("Äàáâäèéêíõöúûü", "Aaaaaeeeioouuu")
    text.gsub(/\([^\(\)]*\)/, "")
  end

  def flavor
    @data["flavor"] || ""
  end

  def power
    @data["power"] ?  @data["power"].to_f : nil
  end

  def toughness
    @data["toughness"] ?  @data["toughness"].to_f : nil
  end

  def loyalty
    @data["loyalty"] ?  @data["loyalty"].to_f : nil
  end

  def method_missing(m)
    if @data.has_key?(m.to_s)
      @data[m.to_s]
    else
      super
    end
  end

  def inspect
    "Card(#{name})"
  end

private

  def color_names
    {"g"=>"Green", "r"=>"Red", "b"=>"Black", "u"=>"Blue", "w"=>"White"}
  end

  def color_codes
    {"White"=>"w", "Blue"=>"u", "Black"=>"b", "Red"=>"r", "Green"=>"g"}
  end
end
