#!/usr/bin/env ruby

file_contents = File.open(__dir__ + "/../resources/8.txt").read

# From the hex strings provided we can determine which ones of these are AES
# ECB encoded by them repeating the same 16 character block. As with ECB
# encoding the same input will produce the same encrypted output.
ecb_encoded = file_contents.split("\n")
  .select do |contents|
    grouped = contents.chars.each_slice(16).group_by(&:to_s)
    grouped.values.any? { |block| block.length > 1 }
  end

puts "ECB encoded: " + ecb_encoded.to_s

