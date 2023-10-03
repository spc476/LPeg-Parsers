package = "org.conman.parsers.soundex"
version = "1.0.1-1"
source = {
   url = "https://raw.github.com/spc476/LPeg-Parsers/soundex-1.0.1/soundex.lua",
   md5 = "1109978152b93c3d267fd7c1f1fef803"
}
description = {
   summary = "Generate the Soundex value for a given word",
   detailed = [[
	This is an LPEG expression that will return the Soundex value for a given word or name.
  ]],
   homepage = "https://github.com/spc476/LPeg-Parsers",
   license = "LGPL3+",
   maintainer = "Sean Conner <sean@conman.org>"
}
dependencies = {
   "lua >= 5.1, <= 5.4",
   "lpeg >= 1.0.0"
}
build = {
   type = "none",
   copy_directory = {},
   install = {
      lua = {
         ["org.conman.parsers.soundex"] = "soundex.lua"
      }
   }
}
