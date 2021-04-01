require_relative '../../lib/compiler/ast_node'

RSpec.describe Compiler::AstNode do
  it 'construction' do
    Compiler::AstNode.new(:Identifier, 'x')
  end

  describe '#is_leaf?' do
    it 'Identifier is leaf node' do
      expect(Compiler::AstNode.new(:Identifier, 'x').is_leaf?).to eq true
    end

    it 'Integer is leaf node' do
      expect(Compiler::AstNode.new(:Integer, 1).is_leaf?).to eq true
    end

    it 'String is leaf node' do
      expect(Compiler::AstNode.new(:String, 'hello world').is_leaf?).to eq true
    end

    it 'Empty is leaf node' do
      expect(Compiler::AstNode.new(:Empty).is_leaf?).to eq true
    end
  end

  describe '#to_s' do
    it 'prints terminal leaf nodes' do
      ast = Compiler::AstNode.new(:Identifier, 'x')
      str = ast.to_s
      expect(str).to eq "Identifier           x\n"
    end

    it 'prints non leaf nodes recursively' do
      ast = Compiler::AstNode.new(
        :Sequence,
        Compiler::AstNode.new(
          :Assign,
          Compiler::AstNode.new(:Identifier, 'a'),
          Compiler::AstNode.new(:Integer, 11)
        )
      )

      str = ast.to_s

      expect(str).to eq <<~AST
        Sequence
        Assign
        Identifier           a
        Integer              11
        ;
      AST
    end
  end
end
