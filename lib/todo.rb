require 'json'
require 'csv'
require 'securerandom'

class Storage
  def read = raise(NotImplementedError, 'Subclasses must implement the read method')
  def write = raise(NotImplementedError, 'Subclasses must implement the write method')
end

class CSVStorage < Storage
  def initialize(file = 'tasks.csv')
    @file = file
    File.write @file, "id,title,description,done\n" unless File.exist? @file
  end

  def read
    tasks = []
    CSV.foreach @file, headers: true, header_converters: :symbol do |row|
      task = row.to_h
      task[:done] = task[:done] == 'true' if task.key? :done
      tasks << task
    end

    tasks
  end

  def write(tasks)
    headers = tasks.first&.keys
    return if headers.nil?

    CSV.open @file, 'w', write_headers: true, headers: headers do |csv|
      tasks.each do |task|
        csv << headers.map { |header| task[header] }
      end
    end
  end
end

class JSONStorage < Storage
  def initialize(file = 'tasks.json')
    @file = file
    File.write @file, '[]' unless File.exist? @file
  end

  def read
    JSON.parse File.read(@file), { symbolize_names: true }
  end

  def write(tasks)
    File.write @file, JSON.pretty_generate(tasks)
  end
end

class MemoryStorage < Storage
  def initialize(tasks = [])
    @tasks = tasks.map { |task| task.transform_keys(&:to_sym) }
  end

  def read
    @tasks
  end

  def write(tasks)
    @tasks = tasks.map { |task| task.transform_keys(&:to_sym) }
  end
end

class Todo
  def initialize(storage)
    @storage = storage
  end

  def list_tasks
    @storage.read
  end

  def find_task(id)
    list_tasks.find { |task| task[:id] == id }
  end

  def delete_task(id)
    tasks = list_tasks
    deleted_task = tasks.find { |task| task[:id] == id }

    return unless deleted_task

    tasks.delete deleted_task
    @storage.write tasks
    deleted_task
  end

  def create_task(title, **attributes)
    raise 'Title is required to create a task' if !title.is_a?(String) || title.empty?

    tasks = list_tasks

    new_task = attributes.merge id: SecureRandom.uuid, title: title, done: false

    tasks << new_task
    @storage.write tasks
    new_task
  end

  def update_task(id, **attributes)
    tasks = list_tasks
    index_task_to_edit = tasks.find_index { |task| task[:id] == id }

    return if index_task_to_edit.nil?

    tasks[index_task_to_edit].merge! attributes.merge id: id
    @storage.write tasks

    tasks[index_task_to_edit]
  end
end
