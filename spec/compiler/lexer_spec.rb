RSpec.describe Compiler::Lexer do
  it 'constructor accepts an input and output stream' do
    input = StringIO.new('')
    output = StringIO.new

    Compiler::Lexer.new(input, output)
  end

  describe '#run' do
    it 'End_of_input' do
      input = StringIO.new('')
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq "   1    1 End_of_input\n"
    end

    it 'Op_multiply' do
      input = StringIO.new('*')
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq <<-TOK
   1    1 Op_multiply
   1    2 End_of_input
      TOK
    end

    it 'Op_divide' do
      input = StringIO.new('/')
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq(
<<-TOK
   1    1 Op_divide
   1    2 End_of_input
TOK
      )
    end

    it 'tokens on more than one line' do
      input = StringIO.new("*\n/\n")
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq <<-TOK
   1    1 Op_multiply
   2    1 Op_divide
   3    1 End_of_input
      TOK
    end

    it 'more than 1 token on a line' do
      input = StringIO.new("* /\n")
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq <<-TOK
   1    1 Op_multiply
   1    3 Op_divide
   2    1 End_of_input
      TOK
    end

    it 'Keyword_if' do
      input = StringIO.new("if")
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq <<-TOK
   1    1 Keyword_if
   1    3 End_of_input
      TOK
    end

    it 'example if else' do
      input = StringIO.new(
        <<~CODE
          if (x == 5) {
            print("hey");
          } else {
            print("hello", "world");
          }
        CODE
      )
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq <<-TOK
   1    1 Keyword_if
   1    4 LeftParen
   1    5 Identifier           x
   1    7 Op_equal
   1   10 Integer              5
   1   11 RightParen
   1   13 LeftBrace
   2    3 Keyword_print
   2    8 LeftParen
   2    9 String               "hey"
   2   14 RightParen
   2   15 Semicolon
   3    1 RightBrace
   3    3 Keyword_else
   3    8 LeftBrace
   4    3 Keyword_print
   4    8 LeftParen
   4    9 String               "hello"
   4   16 Comma
   4   18 String               "world"
   4   25 RightParen
   4   26 Semicolon
   5    1 RightBrace
   6    1 End_of_input
      TOK
    end

    it 'example while statement' do
      input = StringIO.new(
        <<~CODE
          while(foo != 5) {
            putc('c');
          }
        CODE
      )
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq <<-TOK
   1    1 Keyword_while
   1    6 LeftParen
   1    7 Identifier           foo
   1   11 Op_notequal
   1   14 Integer              5
   1   15 RightParen
   1   17 LeftBrace
   2    3 Keyword_putc
   2    7 LeftParen
   2    8 Char                 'c'
   2   11 RightParen
   2   12 Semicolon
   3    1 RightBrace
   4    1 End_of_input
      TOK
    end

    it 'example math operators' do
      input = StringIO.new(
        <<~CODE
          x = 1 + 3 - (4123 * 7) % 2
        CODE
      )
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq <<-TOK
   1    1 Identifier           x
   1    3 Op_assign
   1    5 Integer              1
   1    7 Op_add
   1    9 Integer              3
   1   11 Op_subtract
   1   13 LeftParen
   1   14 Integer              4123
   1   19 Op_multiply
   1   21 Integer              7
   1   22 RightParen
   1   24 Op_mod
   1   26 Integer              2
   2    1 End_of_input
      TOK
    end

    it 'logic operators' do
      input = StringIO.new(
        <<~CODE
          flag = foo && bar || !baz
        CODE
      )
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq <<-TOK
   1    1 Identifier           flag
   1    6 Op_assign
   1    8 Identifier           foo
   1   12 Op_and
   1   15 Identifier           bar
   1   19 Op_or
   1   22 Op_not
   1   23 Identifier           baz
   2    1 End_of_input
      TOK
    end

    it 'inequalities' do
      input = StringIO.new(
        <<~CODE
          (0 <= (((1 > 2) < 5) >= -7))
        CODE
      )
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq <<-TOK
   1    1 LeftParen
   1    2 Integer              0
   1    4 Op_lessequal
   1    7 LeftParen
   1    8 LeftParen
   1    9 LeftParen
   1   10 Integer              1
   1   12 Op_greater
   1   14 Integer              2
   1   15 RightParen
   1   17 Op_less
   1   19 Integer              5
   1   20 RightParen
   1   22 Op_greaterequal
   1   25 Op_subtract
   1   26 Integer              7
   1   27 RightParen
   1   28 RightParen
   2    1 End_of_input
      TOK
    end

    describe 'comments' do
      it 'ignores comments' do
        input = StringIO.new('/*this is a comment*/')
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq "   1   22 End_of_input\n"
      end

      it 'comments can have extra * inside' do
        input = StringIO.new(
          <<~CODE
            /*** this is a comment **/
          CODE
        )
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq <<-TOK
   2    1 End_of_input
        TOK
      end

      it 'complicated comment' do
        input = StringIO.new(
          <<~CODE
            /*** test printing, embedded \\n and comments with lots of '*' ***/
          CODE
        )
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq <<-TOK
   2    1 End_of_input
        TOK
      end

      it 'comments can be multiline' do
        input = StringIO.new(
          <<~CODE
            /*
            this is my comment
            */
          CODE
        )
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq <<-TOK
   4    1 End_of_input
        TOK
      end

      it 'code can follow multiline comment' do
        input = StringIO.new("foo = /* a \ncomment */ 5;")
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq(
          "   1    1 Identifier           foo\n" \
          "   1    5 Op_assign\n" \
          "   2   12 Integer              5\n" \
          "   2   13 Semicolon\n" \
          "   2   14 End_of_input\n"
        )
      end

      it 'comments can be embedded in a line' do
        input = StringIO.new("foo = /* a comment */ 5;")
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq(
          "   1    1 Identifier           foo\n" \
          "   1    5 Op_assign\n" \
          "   1   23 Integer              5\n" \
          "   1   24 Semicolon\n" \
          "   1   25 End_of_input\n"
        )
      end
    end

    it 'embedded \n and comments with lots of "*"' do
      input = StringIO.new(
        <<~CODE
          /*** test printing, embedded \\n and comments with lots of '*' ***/
          print(42);
          print("\\nHello World\\nGood Bye\\nok\\n");
          print("Print a slash n - \\n.\\n");
        CODE
      )
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq <<-TOK
   2    1 Keyword_print
   2    6 LeftParen
   2    7 Integer              42
   2    9 RightParen
   2   10 Semicolon
   3    1 Keyword_print
   3    6 LeftParen
   3    7 String               "\\nHello World\\nGood Bye\\nok\\n"
   3   38 RightParen
   3   39 Semicolon
   4    1 Keyword_print
   4    6 LeftParen
   4    7 String               "Print a slash n - \\n.\\n"
   4   32 RightParen
   4   33 Semicolon
   5    1 End_of_input
      TOK
    end

    describe 'String' do
      it 'can have spaces' do
        input = StringIO.new(
          <<~CODE
            "hello world"
          CODE
        )
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq <<-TOK
   1    1 String               "hello world"
   2    1 End_of_input
        TOK
      end

      it 'newline' do
        input = StringIO.new(
          <<~CODE
            "hello \\n world"
          CODE
        )
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq <<-TOK
   1    1 String               "hello \\n world"
   2    1 End_of_input
        TOK
      end

      it 'backslash' do
        input = StringIO.new(
          <<~CODE
            "\\\\"
          CODE
        )
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq <<-TOK
   1    1 String               "\\\\"
   2    1 End_of_input
        TOK
      end
    end
  end
end
