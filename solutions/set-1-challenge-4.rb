#!/usr/bin/env ruby

require_relative "../crypto"

hashes = File.open("../resources/4.txt").read.split("\n")

hashes_as_bytes = hashes.map { |hash| Crypto.hex_to_bytes(hash) }

best_guesses = hashes_as_bytes.map do |bytes|
  guesses = (0..255).map do |byte|
    key = Crypto.repeated_key(byte.chr, bytes.length).chars.map(&:ord)
    guess = Crypto.xor_byte_buffers(bytes, key).map(&:chr).join
    [byte, guess]
  end

  [bytes, Crypto.sort_by_english_likelihood(guesses).first]
end

most_likely = best_guesses.sort do |(_, (_, a)), (_, (_, b))|
  Crypto.frequent_character_score(b) <=> Crypto.frequent_character_score(a)
end.first

puts "Encrypted hash is: #{Crypto.bytes_to_hex(most_likely.first)}"
puts "Encrypted with byte: #{most_likely.last[0].to_s}"
puts "Decrypted as: #{most_likely.last[1]}"
