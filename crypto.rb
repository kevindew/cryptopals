require "openssl"
require "byebug"

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

  def self.hamming_distance(buffer_1, buffer_2)
    self.xor_byte_buffers(buffer_1, buffer_2).inject(0) do |memo, i|
      memo + i.to_s(2).count("1")
    end
  end

  def self.likely_key_sizes_by_hamming(buffer, min, max)
    if max * 4 > buffer.length
      raise "Only designed for keys <= 4 times the length of the string"
    end
    normalised_hammings = (min..max).map do |size|
      hamming_distances = 4.times.map do |index|
        start = size * index
        first_buffer = buffer[start, size]
        second_buffer = buffer[start + size, size]
        self.hamming_distance(first_buffer, second_buffer)
      end
      normalised = hamming_distances.map { |h| h.to_f / size }
      average = normalised.reduce(:+) / normalised.size
      [size, average]
    end
    normalised_hammings.sort_by(&:last)
  end

  def self.sorted_single_char_attempts(buffer)
    attempts = (0..255).map do |byte|
      key = self.repeated_key(byte.chr, buffer.length).chars.map(&:ord)
      decoded = self.xor_byte_buffers(buffer, key).map(&:chr).join
      [byte, decoded]
    end

    self.sort_by_english_likelihood(attempts)
  end

  # Pad the string/byte array until it is the length of the block.
  # The number of bytes to be added determines which byte is appended.
  # eg. for 5 bytes added each extra byte would have a value of 5
  def self.pkcs7_padding(to_pad, block_size = 16)
    raise "input longer than block size" if to_pad.length > block_size
    bytes = block_size - to_pad.length
    padding = Array.new(bytes, bytes)
    if to_pad.is_a?(String)
      to_pad + padding.map(&:chr).join
    else
      to_pad + padding
    end
  end

  def self.trim_pkcs7_padding(to_trim, block_size = 16)
    raise "input longer than block size" if to_trim.length > block_size
    as_bytes = to_trim.is_a?(String) ? to_trim.bytes : to_trim
    last_byte = as_bytes.last
    potential_padding = as_bytes[(as_bytes.length - last_byte)..-1]
    if potential_padding.length == last_byte && potential_padding.uniq == [last_byte]
      to_trim[0...(last_byte * -1)]
    else
      to_trim
    end
  end

  def self.ecb_encrypt(plain_text, key)
    cipher = OpenSSL::Cipher.new("AES-128-ECB").encrypt
    cipher.key = key
    cipher.update(plain_text) + cipher.final
  end

  def self.ecb_decrypt(encrypted_text, key, with_final: true)
    cipher = OpenSSL::Cipher.new("AES-128-ECB").decrypt
    cipher.key = key
    cipher.update(encrypted_text) + (with_final ? cipher.final : "")
  end

  def self.cbc_decrypt(encrypted_text, key, iv)
    in_blocks = encrypted_text.chars.each_slice(16).map(&:join)
    in_blocks.each_with_index.map do |block, index|
      # seem to need a 17 character here :-/
      block_decrypted = self.ecb_decrypt(block + "\x00", key, with_final: false)
      previous_block = index == 0 ? iv : in_blocks[index - 1]
      xored = self.xor_byte_buffers(block_decrypted.bytes, previous_block.bytes)
      as_string = xored.map(&:chr).join
      index + 1 == in_blocks.length ? trim_pkcs7_padding(as_string) : as_string
    end.join
  end
end
