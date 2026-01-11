module MagicLink::Code
  # Base32 alphabet without confusing characters (no O, I, L)
  # Using Crockford's Base32 variant for human-readable codes
  ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ".chars.freeze
  CODE_SUBSTITUTIONS = { "O" => "0", "I" => "1", "L" => "1" }.freeze

  class << self
    def generate(length)
      Array.new(length) { ALPHABET.sample }.join
    end

    def sanitize(code)
      if code.present?
        normalize_code(code)
          .then { |c| apply_substitutions(c) }
          .then { |c| remove_invalid_characters(c) }
      end
    end

    private

    def normalize_code(code)
      code.to_s.upcase
    end

    def apply_substitutions(code)
      CODE_SUBSTITUTIONS.reduce(code) { |result, (from, to)| result.gsub(from, to) }
    end

    def remove_invalid_characters(code)
      code.gsub(/[^#{ALPHABET.join}]/, "")
    end
  end
end
