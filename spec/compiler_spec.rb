# frozen_string_literal: true

RSpec.describe Compiler do
  it "has a version number" do
    expect(Compiler::VERSION).not_to be nil
  end
end
