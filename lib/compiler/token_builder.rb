module Compiler
  class TokenBuilder
    class << self
      def build(matches, line_no, line_pos)
        type = token_type(matches)
        value = token_value(type, matches)
        Token.new(line_no, line_pos, type, value)
      end

      private

      def token_type(matches)
        matches.named_captures.select { |k, v| v }.map { |k, v| k }.first
      end

      def token_value(type, matches)
        case type
        when 'Identifier', 'String', 'Integer', 'Char'
          matches[type]
        else
          nil
        end
      end
    end
  end
end
