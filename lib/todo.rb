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

  def list_tasks(filters = {})
    repository.list_tasks_by_user_id @user.id, filters
  end

  def find_task(id)
    repository.find_task_by_id @user.id, id
  end

  def delete_task(id)
    task = find_task id
    return if task.nil?

    repository.delete_task_by_id @user.id, id
  end

  def create_task(title, **attributes)
    raise 'Title is required to create a task' unless title.is_a?(String) && !title.empty?

    new_task = {
      user_id: @user.id,
      title: title,
      description: attributes.fetch(:description, ''),
      done: attributes.fetch(:done, false),
      deadline: attributes[:deadline],
      project_id: attributes[:project_id],
    }

    repository.create_task new_task
  end

  def edit_task(id, **attributes)
    task = find_task id
    return if task.nil?

    params = {
      id: id,
      title: attributes.fetch(:title, task.title),
      description: attributes.fetch(:description, task.description),
      done: attributes.fetch(:done, task.done),
      deadline: attributes.key?(:deadline) ? attributes[:deadline] : task.deadline,
      # project_id: attributes.key?(:project_id) ? attributes[:project_id] : task.project_id,
      user_id: @user.id,
    }

    repository.edit_user_task_by_id @user.id, params
  end

  def create_project(name)
    raise 'Project name is required' if name.nil? || name.empty?

    repository.create_project user_id: user.id, name: name
  end

  def find_project_by_name(name)
    repository.find_project_by_name user.id, name
  end

  private

  def repository
    @repository ||= Todo::Repository.new
  end
end
