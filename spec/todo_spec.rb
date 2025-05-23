# require_relative '../lib/todo'

RSpec.describe Todo do
  let(:todo) { Todo }

  describe '.list_tasks' do
    let(:result) { todo.list_tasks }

    it 'returns a list of tasks' do
      expect(result).to all(be_a(Hash))
    end
  end

  describe '.find_task' do
    let(:id) { 'f63a6d6e-3a61-4d57-b043-89606556c050' }
    let(:result) { todo.find_task id }

    it 'finds the desired task' do
      expect(result).to be_a(Hash)
      expect(result['id']).to eq(id)
    end

    context 'With unknown ID' do
      let(:id) { 'bd3a6d6e-3a61-4d57-b043-89606556c050' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '.delete_task' do
    let(:id) { 'f63a6d6e-3a61-4d57-b043-89606556c050' }
    let(:result) { todo.delete_task id }

    it 'retrieves the deleted task' do
      expect(result).to be_a(Hash)
      expect(result['id']).to eq(id)
    end

    context 'With unknown ID' do
      let(:id) { 'bd3a6d6e-3a61-4d57-b043-89606556c050' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end
end
