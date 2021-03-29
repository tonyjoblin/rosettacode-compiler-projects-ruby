module Compiler
  class Token
    attr_reader :line, :pos, :token, :value

    def initialize(line, pos, token, value = nil)
      @line = line
      @pos = pos
      @token = token
      @value = value
    end
  end
end
