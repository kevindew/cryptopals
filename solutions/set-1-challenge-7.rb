#!/usr/bin/env ruby

require_relative "../crypto"
require "base64"
require "openssl"
require "byebug"

decoded = Base64.decode64(File.open("./resources/7.txt").read)

cipher = OpenSSL::Cipher.new("AES-128-ECB").decrypt
cipher.decrypt
cipher.key = "YELLOW SUBMARINE"
output = cipher.update(decoded) + cipher.final

puts output

