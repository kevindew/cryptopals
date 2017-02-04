module Crypto
  def self.hex_to_bytes(hex_string)
    hex_string.scan(/../).map(&:hex)
  end

  def self.bytes_to_hex(bytes)
    bytes.map { |byte| byte.to_s(16).rjust(2, "0") }.join
  end

  # Base64 takes 3 bytes and splits them into 4 6-bit numbers which can be
  # represented as characters
  def self.bytes_to_base64(bytes)
    base64_chars = ("A".."Z").to_a + ("a".."z").to_a + ("0".."9").to_a + %w(+ /)
    # split the array of bytes into groups of 3
    bytes.each_slice(3).inject("") do |memo, (x, y, z)|
      # first 6 bits
      first = x >> 2
      # last 2 bits of x, first 4 bits of y
      second= ((x & 3) << 4) + ((y || 0) >> 4)
      # last 4 bits of y, first 2 bits of z
      third = y ? ((y & 15) << 2) + ((z || 0) >> 6) : nil
      # last 4 bits of z
      fourth = z ? z & 63 : nil
      base64 = [first, second, third, fourth].map do |digit|
        digit == nil ? "=" : base64_chars[digit]
      end
      memo + base64.join
    end
  end

  def self.xor_byte_buffers(buffer_1, buffer_2)
    buffer_1.zip(buffer_2).map { |a, b| a ^ b }
  end

  def self.repeated_key(key, length)
    repeat = (length.to_f / key.length).ceil
    (key * repeat)[0...length]
  end

  def self.sort_by_english_likelihood(guesses)
    guesses.sort do |(_, a), (_, b)|
      self.frequent_character_score(b) <=> self.frequent_character_score(a)
    end
  end

  def self.frequent_character_score(string, match = "ETAOIN SHRDLU")
    string.chars
      .map(&:downcase)
      .select { |c| match.downcase.include?(c) }
      .group_by { |c| c }
      .values
      .inject(0) { |score, letters| score + letters.length }
  end
end
