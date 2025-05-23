require 'json'

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
end
