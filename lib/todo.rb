require 'json'
require 'securerandom'

class Storage
  def read
    raise NotImplementedError
  end

  def write
    raise NotImplementedError
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
    @task = []
  end

  def read 
    @task
  end

  def write(tasks)
    @task = tasks
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

  def add_task(title, description, done)
    tasks = list_tasks

    new_task = {
      'id' => SecureRandom.uuid,
      'title' => title,
      'description' => description,
      'done' => done,
    }

    tasks << new_task
    @storage.write tasks
    new_task
  end

  def edit_task(id, title: nil, description: nil, done: nil)
    tasks = list_tasks
    task = tasks.find { |task| task['id'] == id }
    return unless task

    task['title'] = title if title
    task['description'] = description if description
    task['done'] = done unless done.nil?

    @storage.write tasks
    task
  end
end
