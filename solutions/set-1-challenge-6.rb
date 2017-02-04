#!/usr/bin/env ruby

require_relative "../crypto"
require "base64"
require "byebug"

bytes = Base64.decode64(File.open("./resources/6.txt").read).chars.map(&:ord)

likely_key_sizes = Crypto.likely_key_sizes_by_hamming(bytes, 2, 40).take(3).map(&:first)

key_bytes = likely_key_sizes.map do |size|
  # split the bytes into arrays that are encrypted with same byte from the key
  # eg for a repeated key of [0, 1] and [4,5,6,7] would split into [4,6] and [5,7]
  bytes_by_key_index = bytes.each_with_index
    .group_by { |index| index.last % size }
    .map { |_, byte_with_index| byte_with_index.map(&:first) }

  bytes_by_key_index.map do |single_char_encrypted|
    Crypto.sorted_single_char_attempts(single_char_encrypted).first.first
  end
end

decrypt_attemps = key_bytes.map do |key|
  attempt = Crypto.xor_byte_buffers(bytes, Crypto.repeated_key(key, bytes.length))
  [key, attempt.map(&:chr).join]
end

most_likely = Crypto.sort_by_english_likelihood(decrypt_attemps).first

puts "Key is: " + most_likely.first.map(&:chr).join
puts "Decrypted is: " + most_likely.last
