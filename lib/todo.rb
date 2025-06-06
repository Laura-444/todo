require 'json'
require 'csv'
require 'securerandom'

class TodoError < StandardError
end

class TodoFileReadError < TodoError
end

class TodoFileWriteError < TodoError
end

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
  end

  def read
    content_file = File.read @file
    JSON.parse(content_file, { symbolize_names: true })
  rescue Errno::ENOENT => e
    raise TodoFileReadError, "File '#{@file}' not found: #{e.message}"
  rescue Errno::EACCES => e
    raise TodoFileReadError, "Permission denied to read file '#{@file}': #{e.message}"
  rescue JSON::ParserError => e
    raise TodoFileReadError, "Failed to parse file '#{@file}' invalid Json format: #{e.message}"
  rescue StandardError => e
    raise TodoFileReadError, "Error unexpected: #{e.message}"
  end

  def write(tasks)
    File.write @file, JSON.pretty_generate(tasks)
  rescue Errno::EACCES => e
    raise TodoFileWriteError, "Permission denied to write file '#{@file}': #{e.message}"
  rescue Errno::ENOENT => e
    raise TodoFileWriteError, "File '#{@file}' not found: #{e.message}"
  rescue StandardError => e
    raise TodoFileWriteError, "Error unexpected #{e.message}"
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

    new_task = { id: SecureRandom.uuid, title: title, done: false }.merge attributes

    tasks << new_task
    @storage.write tasks
    new_task
  end

  def edit_task(id, **attributes)
    tasks = list_tasks
    index_task_to_edit = tasks.find_index { |task| task[:id] == id }

    return if index_task_to_edit.nil?

    tasks[index_task_to_edit].merge! attributes.merge id: id
    @storage.write tasks

    tasks[index_task_to_edit]
  end
end
