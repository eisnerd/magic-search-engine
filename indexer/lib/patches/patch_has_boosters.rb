# Data flow between this system and mtgjson is bidirectional
# - index says set has boosters if mtgjson says
# - mtgjson says so because old index said so
# - this is just an extra

class PatchHasBoosters < Patch
  # This just needs to list sets that didn't get to mtgjson yet
  def new_sets_with_boosters
    %W[afr]
  end

  def arena_standard_sets
    %W[
      xln
      rix
      m19
      dom
      grn
      rna
      war
      m20
      eld
      thb
      iko
      m21
      znr
      khm
      stx
      afr
    ]
  end

  def included_in_other_boosters
    %W[
      exp
      mps
      mp2
      tsb
      fmb1
      plist
      sta
    ]
  end

  def call
    each_set do |set|
      booster = set.delete("booster")
      has_own_boosters = !!booster

      if new_sets_with_boosters.include?(set["code"])
        if has_own_boosters
          warn "#{set["code"]} already has boosters, no need to include it in the patch list"
        else
          has_own_boosters = true
        end
      end

      set["has_boosters"] = !!has_own_boosters
      set["in_other_boosters"] = !!included_in_other_boosters.include?(set["code"])

      case set["code"]
      when "ala"
        set["booster_variants"] = {
          "premium" => "Alara Premium Foil Booster",
          "default" => nil,
        }
      when "klr", "akr"
        # Does not have normal boosters
        set["booster_variants"] = {
          "arena" => "#{set["name"]} Arena Booster",
        }
      when *arena_standard_sets
        # Also available on Arena
        set["booster_variants"] = {
          "arena" => "#{set["name"]} Arena Booster",
          "default" => nil,
        }
      else
        if has_own_boosters
          set["booster_variants"] = {
            "default" => nil,
          }
        else
          set["booster_variants"] = nil
        end
      end
    end
  end
end
