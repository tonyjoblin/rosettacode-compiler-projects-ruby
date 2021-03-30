module Compiler
  class Token
    attr_reader :line, :pos, :type, :value

    def initialize(line, pos, type, value = nil)
      @line = line
      @pos = pos
      @type = type
      @value = value
    end
  end
end
