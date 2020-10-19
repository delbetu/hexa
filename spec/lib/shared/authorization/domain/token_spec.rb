# frozen_string_literal: true

require 'spec_helper'
require 'shared/authorization/domain/token'

describe Token do
  describe '#decode' do
    it 'returns null token when nil si passed' do
      result = Token.decode(nil)
      expect(result).to eq('')
    end
  end

  describe 'General use case' do
    it 'can encode and decode passed data' do
      encoded = Token.encode({ foo: ['bar'] })
      expect(Token.decode(encoded)).to eq({ 'foo' => ['bar'] })
    end
  end
end
