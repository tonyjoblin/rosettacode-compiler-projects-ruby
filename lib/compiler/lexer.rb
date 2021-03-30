require_relative './token'
require_relative './token_printer'
require_relative './tokenizer'

module Compiler
  class Lexer
    def initialize(input = $stdin, output = $stdout)
      @input = input
      @output = output
      @printer = TokenPrinter.new(output)
    end

    def run
      source_code = @input.read()
      Tokenizer.new(source_code).next_token do |token|
        @printer.print(token) if print_token?(token)
      end
    end

    private

    def print_token?(token)
      return false if token.type == 'Comment'
      return false if token.type == 'newline'
      true
    end
  end
end
