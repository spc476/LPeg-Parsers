package = "org.conman.parsers.email"
version = "1.1.1-3"

source =
{
  url = "https://raw.github.com/spc476/LPeg-Parsers/email-1.1.1/email.lua",
  md5 = "38c50ad78dd56435d8bdd96383e3332f",
}

description =
{
  homepage = "https://github.com/spc476/LPeg-Parsers",
  maintainer = "Sean Conner <sean@conman.org>",
  license    = "LGPL3+",
  summary    = "Parse RFC-5322 based email messages",
  detailed   = [[
	Return a Lua table with the email headers parsed into individual
	fields.  Any fields not defined are returned in a field called
	'generic'; the name is the raw header name, with the value the
	raw value found.  

	This will also return the character position past the email headers
	to facility reading in the body, if one exists.
  ]]
}

dependencies =
{
  "lua >= 5.1, <= 5.4",
  "lpeg >= 1.0.0"
}

build =
{
  type = "none",
  copy_directories = {},
  install = 
  {
    lua = 
    {
      ['org.conman.parsers.email'] = "email.lua"
    }
  }
}
