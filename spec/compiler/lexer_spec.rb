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

      expect(output.string).to eq(
        "   1    1 Op_multiply\n" \
        "   1    2 End_of_input\n"
      )
    end

    it 'Op_divide' do
      input = StringIO.new('/')
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq(
        "   1    1 Op_divide\n" \
        "   1    2 End_of_input\n"
      )
    end

    it 'tokens on more than one line' do
      input = StringIO.new("*\n/\n")
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq(
        "   1    1 Op_multiply\n" \
        "   2    1 Op_divide\n" \
        "   3    1 End_of_input\n"
      )
    end

    it 'more than 1 token on a line' do
      input = StringIO.new("* /\n")
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq(
        "   1    1 Op_multiply\n" \
        "   1    3 Op_divide\n" \
        "   2    1 End_of_input\n"
      )
    end

    it 'Keyword_if' do
      input = StringIO.new("if")
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq(
        "   1    1 Keyword_if\n" \
        "   1    3 End_of_input\n"
      )
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

      expect(output.string).to eq(
        "   1    1 Keyword_if\n" \
        "   1    4 LeftParen\n" \
        "   1    5 Identifier           x\n" \
        "   1    7 Op_equal\n" \
        "   1   10 Integer              5\n" \
        "   1   11 RightParen\n" \
        "   1   13 LeftBrace\n" \
        "   2    3 Keyword_print\n" \
        "   2    8 LeftParen\n" \
        "   2    9 String               \"hey\"\n" \
        "   2   14 RightParen\n" \
        "   2   15 Semicolon\n" \
        "   3    1 RightBrace\n" \
        "   3    3 Keyword_else\n" \
        "   3    8 LeftBrace\n" \
        "   4    3 Keyword_print\n" \
        "   4    8 LeftParen\n" \
        "   4    9 String               \"hello\"\n" \
        "   4   16 Comma\n" \
        "   4   18 String               \"world\"\n" \
        "   4   25 RightParen\n" \
        "   4   26 Semicolon\n" \
        "   5    1 RightBrace\n" \
        "   6    1 End_of_input\n"
      )
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

      expect(output.string).to eq(
        "   1    1 Keyword_while\n" \
        "   1    6 LeftParen\n" \
        "   1    7 Identifier           foo\n" \
        "   1   11 Op_notequal\n" \
        "   1   14 Integer              5\n" \
        "   1   15 RightParen\n" \
        "   1   17 LeftBrace\n" \
        "   2    3 Keyword_putc\n" \
        "   2    7 LeftParen\n" \
        "   2    8 Char                 'c'\n" \
        "   2   11 RightParen\n" \
        "   2   12 Semicolon\n" \
        "   3    1 RightBrace\n" \
        "   4    1 End_of_input\n"
      )
    end

    it 'example math operators' do
      input = StringIO.new(
        <<~CODE
          x = 1 + 3 - (4123 * 7) % 2
        CODE
      )
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq(
        "   1    1 Identifier           x\n" \
        "   1    3 Op_assign\n" \
        "   1    5 Integer              1\n" \
        "   1    7 Op_add\n" \
        "   1    9 Integer              3\n" \
        "   1   11 Op_subtract\n" \
        "   1   13 LeftParen\n" \
        "   1   14 Integer              4123\n" \
        "   1   19 Op_multiply\n" \
        "   1   21 Integer              7\n" \
        "   1   22 RightParen\n" \
        "   1   24 Op_mod\n" \
        "   1   26 Integer              2\n" \
        "   2    1 End_of_input\n"
      )
    end

    it 'logic operators' do
      input = StringIO.new(
        <<~CODE
          flag = foo && bar || !baz
        CODE
      )
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq(
        "   1    1 Identifier           flag\n" \
        "   1    6 Op_assign\n" \
        "   1    8 Identifier           foo\n" \
        "   1   12 Op_and\n" \
        "   1   15 Identifier           bar\n" \
        "   1   19 Op_or\n" \
        "   1   22 Op_not\n" \
        "   1   23 Identifier           baz\n" \
        "   2    1 End_of_input\n"
      )
    end

    it 'inequalities' do
      input = StringIO.new(
        <<~CODE
          (0 <= (((1 > 2) < 5) >= -7))
        CODE
      )
      output = StringIO.new

      Compiler::Lexer.new(input, output).run

      expect(output.string).to eq(
        "   1    1 LeftParen\n" \
        "   1    2 Integer              0\n" \
        "   1    4 Op_lessequal\n" \
        "   1    7 LeftParen\n" \
        "   1    8 LeftParen\n" \
        "   1    9 LeftParen\n" \
        "   1   10 Integer              1\n" \
        "   1   12 Op_greater\n" \
        "   1   14 Integer              2\n" \
        "   1   15 RightParen\n" \
        "   1   17 Op_less\n" \
        "   1   19 Integer              5\n" \
        "   1   20 RightParen\n" \
        "   1   22 Op_greaterequal\n" \
        "   1   25 Op_subtract\n" \
        "   1   26 Integer              7\n" \
        "   1   27 RightParen\n" \
        "   1   28 RightParen\n" \
        "   2    1 End_of_input\n"
      )
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

        expect(output.string).to eq("   2    1 End_of_input\n")
      end

      it 'complicated comment with extra * and newlines inside' do
        input = StringIO.new(
          <<~CODE
            /*** test printing, embedded \\n and comments with lots of '*' ***/
          CODE
        )
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq "   2    1 End_of_input\n"
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

        expect(output.string).to eq "   4    1 End_of_input\n"
      end

      it 'multiline comment tracks line pos after comment' do
        input = StringIO.new("/* a\ncomment */")
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq "   2   11 End_of_input\n"
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

    describe 'String' do
      it 'can have spaces' do
        input = StringIO.new(
          <<~CODE
            "hello world"
          CODE
        )
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq(
          "   1    1 String               \"hello world\"\n" \
          "   2    1 End_of_input\n"
        )
      end

      it 'embedded newlines' do
        input = StringIO.new(
          <<~CODE
            "hello \\n world"
          CODE
        )
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq(
          "   1    1 String               \"hello \\n world\"\n" \
          "   2    1 End_of_input\n"
        )
      end

      it 'embedded backslashes' do
        input = StringIO.new(
          <<~CODE
            "\\\\"
          CODE
        )
        output = StringIO.new

        Compiler::Lexer.new(input, output).run

        expect(output.string).to eq(
          "   1    1 String               \"\\\\\"\n" \
          "   2    1 End_of_input\n"
        )
      end
    end
  end
end
