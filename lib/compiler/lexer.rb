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
      @input.each_line { |line| tokenize_line(line) }
      write_token :End_of_input
    end

    private

    def build_regexp
      Regexp.new TOKENS.map { |k, v| "(?<#{k}>#{v})" }.join('|')
    end

    def tokenize_line(line)
      start_pos = 0
      loop do
        matches = @regexp.match(line, start_pos)

        if !matches
          break
        elsif matches[:newline]
          @line_no += 1
          @line_pos = 1
          break
        end

        token = matches.named_captures.select { |k, v| v }.map { |k, v| k }.first
        value = token_value(token, matches)
        @line_pos = matches.begin(0) + 1
        write_token(token, value) unless ignore_token?(token)
        start_pos = matches.end(0)
        @line_pos = start_pos + 1
      end
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
