#!/usr/bin/env ruby

require_relative "../crypto"

stanza = "Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal"

key = Crypto.repeated_key("ICE", stanza.length)

encrypted = Crypto.xor_byte_buffers(stanza.chars.map(&:ord), key.chars.map(&:ord))

puts "Encrypted: " + Crypto.bytes_to_hex(encrypted)
