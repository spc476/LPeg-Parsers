package = "org.conman.parsers.email"
version = "1.2.0-1"
source = {
   url = "https://raw.github.com/spc476/LPeg-Parsers/email-1.2.0/email.lua",
   md5 = "c0cc5fdfc6b2db661e4b02f28bb438fa"
}
description = {
   summary = "Parse RFC-5322 based email messages",
   detailed = [[
	Return a Lua table with the email headers parsed into individual
	fields.  Any fields not defined are returned in a field called
	'generic'; the name is the raw header name, with the value the
	raw value found.  

	This will also return the character position past the email headers
	to facility reading in the body, if one exists.
  ]],
   homepage = "https://github.com/spc476/LPeg-Parsers",
   license = "LGPL3+",
   maintainer = "Sean Conner <sean@conman.org>"
}
dependencies = {
   "lua  >= 5.1,   < 5.5",
   "lpeg >= 1.0.0, < 2.0.0"
}
build = {
   type = "none",
   copy_directories = {},
   install = {
      lua = {
         ["org.conman.parsers.email"] = "email.lua"
      }
   }
}
