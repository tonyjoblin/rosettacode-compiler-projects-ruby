module Compiler
  class Lexer
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

    def initialize(input = $stdin, output = $stdout)
      @input = input
      @output = output
      @line_no = 1
      @line_pos = 1
      @regexp = build_regexp
    end

    def run
      source_code = @input.read()
      tokenize(source_code)
      write_token :End_of_input
    end

    private

    def build_regexp
      pattern = TOKENS.map { |k, v| "(?<#{k}>#{v})" }.join('|')
      Regexp.new(pattern, Regexp::MULTILINE)
    end

    def tokenize(source_code)
      line_starts_at = 0
      start_pos = 0
      loop do
        matches = @regexp.match(source_code, start_pos)

        break if !matches

        token = matched_token(matches)
        if token == 'newline'
          @line_no += 1
          @line_pos = 1
          line_starts_at = matches.end(0)
        elsif token == 'Comment'
          comment_lines = matches[0].split("\n")
          if comment_lines.length > 1
            @line_no += comment_lines.length - 1
            line_starts_at = @line_pos + matches[0].length - comment_lines[-1].length
            @line_pos = comment_lines[-1].length + 1
          else
            @line_pos = matches.end(0) - line_starts_at + 1
          end
        else
          value = token_value(token, matches)
          @line_pos = matches.begin(0) - line_starts_at + 1
          write_token(token, value) unless ignore_token?(token)
          @line_pos = matches.end(0) - line_starts_at + 1
        end

        start_pos = matches.end(0)
      end
    end

    def matched_token(matches)
      matches.named_captures.select { |k, v| v }.map { |k, v| k }.first
    end

    def ignore_token?(token)
      case token
      when 'Comment'
        true
      else
        false
      end
    end

    def token_value(token, matches)
      case token
      when 'Identifier', 'String', 'Integer', 'Char'
        matches[token]
      else
        nil
      end
    end

    def write_token(token, value = nil)
      if value
        @output.write("#{line_no_str} #{line_pos_str} #{token_str(token)} #{value}\n")
      else
        @output.write("#{line_no_str} #{line_pos_str} #{token}\n")
      end
    end

    def line_no_str
      sprintf('%4d', @line_no)
    end

    def line_pos_str
      sprintf('%4d', @line_pos)
    end

    def token_str(token)
      sprintf('%-20s', token)
    end
  end
end
