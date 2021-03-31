require_relative './token'

module Compiler
  class TokenReader
    def initialize(input)
      @input = input
    end

    def read
      tokens = []
      @input.each_line do |line|
        line_no, line_pos, type, value = line.split
        tokens << Token.new(line_no.to_i, line_pos.to_i, type, value)
      end
      tokens
    end
  end
end
