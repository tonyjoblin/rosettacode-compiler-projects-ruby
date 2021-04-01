module Compiler
  class AstNode
    def initialize(type, left = nil, right = nil)
      @type = type
      @left = left
      @right = right
    end

    def to_s
      return "#{print_type} #{@left}\n" if is_leaf?
      "#{@type}\n#{@left}#{@right || ";\n"}"
    end

    def is_leaf?
      @type == :Identifier || @type == :Integer || @type == :String || @type == :Empty
    end

    private

    def print_type
      sprintf('%-20s', @type)
    end
  end
end
