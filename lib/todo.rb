require 'json'
require 'securerandom'

module Todo
  extend self

  def list_tasks
    JSON.parse File.read('tasks.json')
  end

  def find_task(id)
    list_tasks.find { |task| task['id'] == id }
  end

  def delete_task(id)
    tasks = list_tasks
    deleted_task = tasks.find { |task| task['id'] == id }

    return nil unless deleted_task

    tasks.delete deleted_task
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
    File.write 'tasks.json', JSON.pretty_generate(tasks)
    new_task
  end

  def edit_task(id, title: nil, description: nil, done: nil)
    tasks = list_tasks
    task = tasks.find { |task| task['id'] == id }
    return nil unless task

    task['title'] = title if title
    task['description'] = description if description
    task['done'] = done unless done.nil?

    File.write 'tasks.json', JSON.pretty_generate(tasks)
    task
  end
end
