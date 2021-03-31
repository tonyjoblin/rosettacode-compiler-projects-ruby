require_relative '../../lib/compiler/token.rb'
require_relative '../../lib/compiler/token_reader.rb'

RSpec.describe Compiler::TokenReader do
  it 'construct with an io string for input' do
    Compiler::TokenReader.new(StringIO.new)
  end

  describe '#read' do
    it 'returns an array' do
      tokens = Compiler::TokenReader.new(StringIO.new).read
      expect(tokens).to be_instance_of Array
    end

    it 'reads lex output and yields token objects' do
      input = StringIO.new("1 2 type1 value1\n2 3 type2")

      tokens = Compiler::TokenReader.new(input).read

      expect(tokens.length).to eq 2
      expect(tokens[0]).to have_attributes(
        line: 1,
        pos: 2,
        type: 'type1',
        value: 'value1'
      )
      expect(tokens[1]).to have_attributes(
        line: 2,
        pos: 3,
        type: 'type2',
        value: nil
      )
    end
  end
end
