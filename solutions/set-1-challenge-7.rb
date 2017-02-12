#!/usr/bin/env ruby

require_relative "../crypto"
require "base64"

decoded = Base64.decode64(File.open("./resources/7.txt").read)

puts Crypto.ecb_decrypt(decoded, "YELLOW SUBMARINE")

