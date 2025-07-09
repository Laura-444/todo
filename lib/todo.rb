require 'json'
require 'csv'
require 'securerandom'
require 'pg'
require 'sequel'

require_relative 'todo/errors'
require_relative 'todo/storage'

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
    deleted_task = find_task(id)

    return unless deleted_task

    tasks.delete deleted_task
    @storage.write tasks
    deleted_task
  end

  def create_task(title, **attributes)
    raise 'Title is required to create a task' if !title.is_a?(String) || title.empty?

    tasks = list_tasks

    new_task = attributes.merge { id: SecureRandom.uuid, title: title}

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
