#!/usr/bin/env ruby

require_relative "../crypto.rb"
require "base64"

decoded = Base64.decode64(File.open(__dir__ + "/../resources/10.txt").read)
puts Crypto.cbc_decrypt(decoded, "YELLOW SUBMARINE", Crypto.repeated_key("\x00", 16))
