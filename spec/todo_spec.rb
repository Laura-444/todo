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
    let :tasks do
      [
        { 'id' => '123', 'title' => 'Call the vet', 'descripcion' => 'appointment for vaccines', 'done' => false },
        { 'id' => '567', 'title' => 'Go to the store', 'descripcion' => 'buy vegetables', 'done' => false },
      ]
    end

    let :storage do
      s = InMemoryStorage.new
      s.write tasks
      s
    end

    let(:todo) { Todo.new storage }
    let(:result) { todo.find_task id }

    context 'When ID exist' do
      let(:id) { '123' }

      it 'finds the desired task' do
        expect(result).to be_a(Hash)
        expect(result['id']).to eq(id)
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
    let :tasks do
      [
        { 'id' => '123',
          'title' => 'Call the vet',
          'descripcion' => 'appointment for vaccines',
          'done' => false,  },
        { 'id' => '567',
          'title' => 'Go to the store',
          'descripcion' => 'buy vegetables',
          'done' => false, },
      ]
    end

    let :storage do
      s = InMemoryStorage.new
      s.write tasks
      s
    end

    let(:todo) { Todo.new storage }
    let(:result) { todo.find_task id }

    let(:id) { '123' }
    let(:result) { todo.delete_task id }

    it 'retrieves the deleted task' do
      expect(result).to be_a(Hash)
      expect(result['id']).to eq(id)
    end

    context 'With unknown ID' do
      let(:id) { 'c050' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '.add_task' do
    let :storage do
      s = InMemoryStorage.new
      s.write []
      s
    end

    let(:todo) { Todo.new storage }

    let(:title) { 'Prepare project' }
    let(:description) { 'Test description' }
    let(:done) { false }
    let(:result) { todo.add_task title, description, done }

    it 'create a new task' do
      expect(result).to be_a(Hash)
      expect(result['title']).to eq(title)
      expect(result['description']).to eq(description)
      expect(result['done']).to eq(false)
      expect(result['id']).not_to be_nil
    end
  end

  describe '.edit_task' do
    let :tasks do
      [
        { 'id' => '123',
          'title' => 'Call the vet',
          'description' => 'appointment for vaccines',
          'done' => false, },
      ]
    end

    let :storage do
      s = InMemoryStorage.new
      s.write tasks
      s
    end

    let(:todo) { Todo.new storage }
    let(:id) { '123' }

    it 'edits an existing task' do
      new_title = 'Call the vet'
      new_description = 'Checkup on the right paw'

      result = todo.edit_task(
        id,
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
