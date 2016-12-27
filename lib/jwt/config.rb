# frozen_string_literal: true
module Jwt
  class Config
    attr_reader :keys, :key_algorithm, :expiration_time, :issuer

    def initialize(conf_hash)
      @keys = []
      conf_hash['keys'].each do |key|
        @keys << OpenSSL::PKey::EC.new(
          File.open(key, "rb").read
        )
      end
      @key_algorithm = conf_hash['key_algorithm']
      @expiration_time = conf_hash['expiration_time']
      @issuer = conf_hash['issuer']
    end

    def public_key
      @pub_key ||= OpenSSL::PKey::EC.new(key).tap { |pk| pk.private_key = nil }
    end
  end
end
