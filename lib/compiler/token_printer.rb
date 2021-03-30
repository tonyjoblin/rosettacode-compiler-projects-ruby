module Compiler
  class TokenPrinter
    def initialize(output)
      @output = output
    end

    def print(token)
      if token.value
        print_token_with_value(token)
      else
        print_token_without_value(token)
      end
    end

    private

    def print_token_with_value(token)
      print_line_and_position(token)
      @output.write("#{token_str(token)} #{token.value}\n")
    end

    def print_token_without_value(token)
      print_line_and_position(token)
      @output.write("#{token.type}\n")
    end

    def print_line_and_position(token)
      @output.write("#{line_no_str(token)} #{line_pos_str(token)} ")
    end

    def line_no_str(token)
      sprintf('%4d', token.line)
    end

    def line_pos_str(token)
      sprintf('%4d', token.pos)
    end

    def token_str(token)
      sprintf('%-20s', token.type)
    end
  end
end
