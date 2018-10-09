class FormatModern < Format
  def format_pretty_name
    "Modern"
  end

  def build_included_sets
    Set[
      "8ed",
      "mi", "ds", "5dn",
      "chk", "bok", "sok",
      "9ed",
      "rav", "gp", "di",
      "cs",
      "ts", "tsts", "pc", "fut",
      "10e",
      "lw", "mt", "shm", "eve",
      "ala", "cfx", "arb",
      "m10",
      "zen", "wwk", "roe",
      "m11",
      "som", "mbs", "nph",
      "m12",
      "isd", "dka", "avr",
      "m13",
      "rtr", "gtc", "dgm",
      "m14",
      "ths", "bng", "jou",
      "m15",
      "ktk", "frf", "dtk",
      "ori",
      "bfz", "ogw",
      "soi", "w16", "emn",
      "kld", "aer",
      "akh", "w17", "hou",
      "xln", "rix",
      "dom",
      "m19",
      "grn",
    ]
  end
end
