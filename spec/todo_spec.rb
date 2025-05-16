require_relative '../lib/todo'

RSpec.describe Todo do
  describe '.hi' do
    it 'salutes' do
      expect(Todo.hi('Lau')).to eq('Hi Lau')
    end
  end
end
