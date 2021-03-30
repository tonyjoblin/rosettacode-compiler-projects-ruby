require_relative './token_builder'

module Compiler
  class Tokenizer
    TOKENS = {
      Comment: '\/\*.*\*\/',
      Keyword_if: 'if',
      Keyword_else: 'else',
      Keyword_print: 'print',
      Keyword_while: 'while',
      Keyword_putc: 'putc',
      Op_multiply: '\*',
      Op_divide: '\/',
      Op_mod: '%',
      Op_add: '\+',
      Op_subtract: '-',
      Op_equal: '==',
      Op_notequal: '!=',
      Op_greaterequal: '\>=',
      Op_greater: '\>',
      Op_lessequal: '\<=',
      Op_less: '\<',
      Op_assign: '=',
      Op_not: '!',
      Op_and: '&&',
      Op_or: '\|\|',
      LeftParen: '\(',
      RightParen: '\)',
      LeftBrace: '\{',
      RightBrace: '\}',
      Semicolon: ';',
      Comma: ',',
      Integer: '\d+',
      String: '"[^"\n]*"',
      Char:   '\'\w\'',
      Identifier: '[_a-zA-Z][a-zA-Z0-9_]*',
      newline: '\n'
    }

    def initialize(source_code)
      @regexp = build_regexp
      @source_code = source_code
      @line_no = 1
      @line_starts_at = 0
    end

    def next_token
      return unless block_given?

      tokens do |matches|
        token = TokenBuilder.build(matches, @line_no, matches.begin(0) - @line_starts_at + 1)
        yield token

        if token.type == 'newline'
          @line_no += 1
          @line_starts_at = matches.end(0)
        elsif token.type == 'Comment'
          comment_lines = matches[0].split("\n")
          if comment_lines.length > 1
            @line_no += comment_lines.length - 1
            @line_starts_at = matches.end(0) - comment_lines[-1].length
          end
        end
      end

      yield Token.new(@line_no, @source_code.length - @line_starts_at + 1, :End_of_input)
    end

    private

    def tokens
      current_pos_in_src = 0

      loop do
        matches = @regexp.match(@source_code, current_pos_in_src)
        break if !matches

        yield matches

        current_pos_in_src = matches.end(0)
      end
    end

    def build_regexp
      pattern = TOKENS.map { |k, v| "(?<#{k}>#{v})" }.join('|')
      Regexp.new(pattern, Regexp::MULTILINE)
    end
  end
end
