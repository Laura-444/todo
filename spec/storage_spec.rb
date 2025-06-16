RSpec.describe MemoryStorage do
  let :test_tasks do
    [
      { id: '2', title: 'buy vegetables', done: false },
      { id: '5', title: 'buy fruits', done: false },
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
  let(:file_name) { 'example_test.json' }
  let(:storage) { JSONStorage.new file_name }

  describe '.read' do
    let(:result) { storage.read }

    context 'with a valid file' do
      before do
        JSON.dump([{ id: '1', title: 'something', done: false }], File.open(file_name, 'w'))
      end

      it 'reads a desired file' do
        expect(result).to all(be_a(Hash))
        expect(result.first[:title]).to eq('something')
      end
    end

    context 'with invalid JSON file' do
      before { File.write file_name, 'invalid json {' }

      it 'Return an excepcion' do
        expect { storage.read }.to raise_error(TodoFileReadError)
      end
    end
  end

  describe '.write' do
    let(:result) { storage.write [{ id: '1', title: 'nothing' }] }

    it 'writes a desired file' do
      expect(result).to be_a(File)
      content = JSON.parse File.read(file_name)
      expect(content.first['title']).to eq('nothing')
    end
  end
end

RSpec.describe CSVStorage do
  let(:file_name) { 'example_test.csv' }
  let(:storage) { CSVStorage.new file_name }

  describe '.read' do
    let(:result) { storage.read }

    context 'with valid file' do
      before do
        CSV.open file_name, 'w', write_headers: true, headers: %w[id title done] do |csv|
          csv << ['1', 'read book', 'false']
        end
      end

      it 'reads a desired file' do
        expect(result).to all(be_a(Hash))
        expect(result.first[:title]).to eq('read book')
      end
    end

    context 'with invalid file' do
      before { File.write file_name, "id,title\n4\"" }

      it 'return an excepcion' do
        expect { storage.read }.to raise_error(TodoFileReadError)
      end
    end
  end

  describe '.write' do
    let(:tasks) { [{ id: '1', title: 'nothing', done: false }] }

    before do
      storage.write tasks
    end

    it 'writes a desired file' do
      content = CSV.read(file_name, headers: true, header_converters: :symbol).map(&:to_h)
      content.each { |task| task[:done] = task[:done] == 'true' }
      expect(content).to eq(tasks)
    end
  end
end
