require 'json'
require 'csv'
require 'securerandom'
require 'pg'
require 'sequel'

require_relative 'todo/errors'
require_relative 'todo/storage'
require_relative 'todo/repository'
require_relative 'todo/entities'

class Todo
  attr_reader :user

  def initialize(username, force: false)
    @user = repository.find_user_by_username username

    return unless user.nil?
    raise Todo::InvalidUsernameError.new('username no found') unless force

    @user = repository.create_user username
  end

  def list_tasks
    repository.list_tasks_by_user_id user.id
  end

  def find_task(_id)
    repository.find_task_by_id
  end

  def delete_task(id)
    task = repository.find_task_by_id id
    return if task.nil?

    repository.delete_task_by_id id
  end

  def create_task(title, **attributes)
    raise 'Title is required to create a task' if !title.is_a?(String) || title.empty?

    task = {
      user_id: user.id,
      title: title,
      description: attributes.fetch(:description, ''),
      done: attributes.fetch(:done, false),
      deadline: attributes[:deadline],
    }

    repository.create_task task
  end

  def edit_task(id, **attributes)
    task = repository.find_task_by_id id
    # index_task_to_edit = tasks.find_index { |task| task.id == id }
    return if task.nil?

    # tasks[index_task_to_edit].merge! attributes.merge id: id
    repository.edit_user_task_by_id({
      id: id,
      title: attributes.fetch(:title, task.title),
      description: attributes.fetch(:description, task.description),
      done: attributes.fetch(:done, task.done),
      deadline: attributes.key?(:deadline) ? attributes[:deadline] : task.deadline,
    })
  end

  private

  def repository
    @repository ||= Todo::Repository.new
  end
end
