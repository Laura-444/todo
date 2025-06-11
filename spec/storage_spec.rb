RSpec.describe MemoryStorage do
  let :test_tasks do
    [
      { id: '2', title: 'hacer una tarea', done: false },
      { id: '5', title: 'ir de compras', done: false },
    ]
  end

  let(:storage) { MemoryStorage.new test_tasks }

  describe 'read' do
    it 'reads the tasks' do
      result = storage.read
      expect(result).to eq(test_tasks)
    end
  end

  describe 'write' do
    let :new_tasks do
      [
        { id: '7', title: 'read the book', done: false },
      ]
    end

    it 'reeplaces existing task' do
      storage.write new_tasks
      result = storage.read

      expect(result).to eq(new_tasks)
    end
  end
end

RSpec.describe JSONStorage do
  let(:file) { 'example_test.json' }

  let :test_tasks do
    [
      { id: '2', title: 'drink water', done: false },
      { id: '5', title: 'read the book', done: true },
    ]
  end

  let(:storage) { JSONStorage.new file }

  describe 'write and read' do
    it 'writes and reads the tasks' do
      storage.write test_tasks
      result = storage.read

      expect(result).to eq(test_tasks)
    end
  end
end

RSpec.describe CSVStorage do
  let(:file) { 'example_test.csv' }

  let :test_tasks do
    [
      { id: '2', title: 'drink water', done: false },
      { id: '5', title: 'read the book', done: true },
    ]
  end

  let(:storage) { CSVStorage.new file }

  describe 'write and read' do
    it 'writes and reads the tasks' do
      storage.write test_tasks
      result = storage.read

      expect(result).to eq(test_tasks)
    end
  end
end
