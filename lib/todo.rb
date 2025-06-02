require 'json'
require 'csv'
require 'securerandom'

class Storage
  def read = raise(NotImplementedError)
  def write = raise(NotImplementedError)
end

class CSVStorage < Storage
  def initialize(file = 'tasks.csv')
    @file = file
    File.write @file, "id,title,description,done\n" unless File.exist? @file
  end

  def read
    CSV.read(@file, headers: true).map(&:to_h)
  end

  def write(tasks)
    CSV.open @file, 'w', write_headers: true, headers: %w[id title description done] do |csv|
      tasks.each do |task|
        csv << [task['id'], task['title'], task['description'], task['done']]
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
    JSON.parse File.read(@file)
  end

  def write(tasks)
    File.write @file, JSON.pretty_generate(tasks)
  end
end

class InMemoryStorage < Storage
  def initialize
    @tasks = []
  end

  def read
    @tasks
  end

  def write(tasks)
    @tasks = tasks
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
    list_tasks.find { |task| task['id'] == id }
  end

  def delete_task(id)
    tasks = list_tasks
    deleted_task = tasks.find { |task| task['id'] == id }

    return unless deleted_task

    tasks.delete deleted_task
    @storage.write tasks
    deleted_task
  end

  def create_task(title, **attributes)
    tasks = list_tasks

    new_task = attributes.merge id: SecureRandom.uuid, title: title, done: false

    tasks << new_task
    @storage.write tasks
    new_task
  end

  def update_task(id, **attributes)
    tasks = list_tasks
    task = tasks.find { |task| task['id'] == id }
    return unless task

    attributes.each do |key, value|
      task[key.to_s] = value
    end

    @storage.write tasks
    task
  end
end
