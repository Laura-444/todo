# require_relative '../lib/todo'

RSpec.describe Todo do
  let(:storage) { InMemoryStorage.new }
  let(:todo) { Todo.new storage }

  describe '.list_tasks' do
    let(:result) { todo.list_tasks }

    it 'returns a list of tasks' do
      expect(result).to eq([])
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

  describe '.add_task' do
    let(:title) { 'Prepare project' }
    let(:description) { 'Test description' }
    let(:done) { false }
    let(:result) { todo.add_task title: title, description: description, done: false }

    it 'create a new task' do
      expect(result).to be_a(Hash)
      expect(result['title']).to eq(title)
      expect(result['description']).to eq(description)
      expect(result['done']).to eq(false)
      expect(result['id']).not_to be_nil
    end
  end

  describe '.edit_task' do
    let :original_task do
      todo.add_task(
        title: 'Learn about flowers',
        description: 'Wather the plants every morning for a week',
        done: false
      )
    end

    let(:id) { original_task['id'] }

    it 'edits an existing task' do
      new_title = 'Call the vet'
      new_description = 'Checkup on the right paw'

      result = Todo.edit_task(
        id: id,
        title: new_title,
        description: new_description,
        done: true
      )

      expect(result).to be_a(Hash)
      expect(result['id']).to eq(id)
      expect(result['title']).to eq(new_title)
      expect(result['description']).to eq(new_description)
      expect(result['done']).to eq(true)
    end

    context 'when the task ID does not exist' do
      it 'return nil' do
        result = Todo.edit_task(
          id: 'non-existent-id',
          title: 'Should not work'
        )

        expect(result).to be_nil
      end
    end
  end
end
