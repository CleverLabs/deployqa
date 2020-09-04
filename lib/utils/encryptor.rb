# frozen_string_literal: true

module Utils
  class Encryptor
    def initialize
      @key = ENV["ENCRYPTION_KEY"]
    end

    def encrypt(string)
      cipher = OpenSSL::Cipher.new("aes-256-cbc").encrypt
      cipher.key = @key
      result = cipher.update(string) + cipher.final

      result.unpack1("H*").upcase
    end

    def decrypt(string)
      unpacked_string = [string].pack("H*").unpack("C*").pack("c*")

      cipher = OpenSSL::Cipher.new("aes-256-cbc").decrypt
      cipher.key = @key
      cipher.update(unpacked_string) + cipher.final
    end

    def decrypt_json(string)
      JSON.parse(decrypt(string))
    end
  end
end
