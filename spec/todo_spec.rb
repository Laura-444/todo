RSpec.describe Todo do
  let(:storage) { MemoryStorage.new }
  let(:todo) { Todo.new storage }

  let :testTasks do
    [
      { id: '123',
        title: 'Call the vet',
        description: 'appointment for vaccines',
        done: false,  },
      { id: '567',
        title: 'Go to the store',
        description: 'buy vegetables',
        done: false, },
    ]
  end

  before do
    storage.write testTasks
  end

  describe '.list_tasks' do
    let(:result) { todo.list_tasks }

    it 'returns a list of tasks' do
      expect(result).to all(be_a(Hash))
    end
  end

  describe '.find_task' do
    let(:result) { todo.find_task id }

    context 'When ID exist' do
      let(:id) { '123' }

      it 'finds the desired task' do
        expect(result).to be_a(Hash)
        expect(result[:id]).to eq(id)
        expect(result[:title]).to eq('Call the vet')
      end
    end

    context 'With unknown ID' do
      let(:id) { 'bc050' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '.delete_task' do
    let(:id) { '123' }
    let(:result) { todo.delete_task id }

    it 'retrieves the deleted task' do
      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(id)
    end

    context 'With unknown ID' do
      let(:id) { 'c050' }

      it 'returns nil' do
        expect(todo.delete_task(id)).to be_nil
      end
    end
  end

  describe '.create_task' do
    before { storage.write [] }

    let(:title) { 'Prepare project' }
    let(:description) { 'Test description' }

    let :result do
      todo.create_task title, description: description, done: false
    end

    it 'create a new task' do
      expect(result).to be_a(Hash)
      expect(result[:title]).to eq(title)
      expect(result[:description]).to eq(description)
      expect(result[:done]).to eq(false)
      expect(result[:id]).not_to be_nil
    end
  end

  describe '.edit_task' do
    let(:id) { '123' }

    it 'edits an existing task' do
      new_title = 'Buy book'
      new_description = 'IT'
      new_done = true

      result = todo.edit_task(
        id,
        title: new_title,
        description: new_description,
        done: new_done
      )

      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(id)
      expect(result[:title]).to eq(new_title)
      expect(result[:description]).to eq(new_description)
      expect(result[:done]).to eq(new_done)
    end

    context 'when the task ID does not exist' do
      it 'returns nil' do
        result = todo.edit_task(
          'non-existent-id',
          title: 'invalid ID'
        )
        expect(result).to be_nil
      end
    end
  end
end
