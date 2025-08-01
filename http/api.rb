require 'sinatra/base'
require_relative '../lib/todo'

class Api < Sinatra::Base
  set :environment, :production
  set :default_content_type, :json
  disable :dump_errors, :raise_errors

  before do
    @json_params = {}

    if request.content_type == 'application/json'
      begin
        body = request.body.read
        @json_params = JSON.parse(body) unless body.strip.empty?
      rescue JSON::ParserError
        halt 400, { error: 'Invalid JSON format' }.to_json
      end
    end

    @username = ENV['TODO_USERNAME'] || error_response(400, 'TODO_USERNAME not set')
    @todo = todo
  end

  def username
    ENV['TODO_USERNAME'] || halt(400, { error: 'TODO_USERNAME not set' }.to_json)
  end

  def todo
    @todo ||= Todo.new username
  rescue Todo::InvalidUsernameError
    @todo = Todo.new username, force: true
  end

  def parse_epoch_to_timestamp(epoch)
    Time.at(epoch.to_i).utc.iso8601
  rescue StandardError
    nil
  end

  def parse_done(value)
    case value.to_s.downcase
    when 'true', 't', '1' then true
    when 'false', 'f', '0' then false
    end
  end

  get '/' do
    { message: 'API funcionando' }.to_json
  end
  get '/tasks' do
    done, title, start_deadline, end_deadline = params.values_at(
      :done,
      :title,
      :start_deadline,
      :end_deadline
    )

    done = parse_done(done) unless done.nil?

    unless start_deadline.nil?
      original = start_deadline
      start_deadline = parse_epoch_to_timestamp start_deadline
      halt 400, { error: "Invalid start_deadline. Expected epoch, got: #{original}" }.to_json
    end

    unless end_deadline.nil?
      original = end_deadline
      end_deadline = parse_epoch_to_timestamp end_deadline
      halt 400, { error: "Invalid end_deadline. Expected epoch, got: #{original}" }.to_json
    end

    tasks = todo.list_tasks(
      title: title,
      done: done,
      start_deadline: start_deadline,
      end_deadline: end_deadline
    )

    { result: tasks }.to_json
  rescue StandardError => e
    halt 500, { error: e.message }.to_json
  end

  get '/task/:id' do
    task = todo.find_task params[:id]
    halt 404, { error: 'Task not found' }.to_json unless task

    task.to_json
  end

  delete '/tasks/:id' do
    delete = todo.delete_task params[:id]
    halt 404, { error: 'Task not found' }.to_json unless delete

    delete.to_json
  end

  post '/tasks' do
    title = @json_params['title']
    halt 400, { error: 'Title is required' }.to_json if title.nil? || title.strip.empty?

    attributes = {}
    attributes[:title] = @json_params['title'] if @json_params['title']
    attributes[:description] = @json_params['description'] if @json_params['description']
    attributes[:done] = true if @json_params['done'] == true
    attributes[:done] = false if @json_params['done'] == false
    attributes[:deadline] = @json_params['deadline'] if @json_params['deadline']

    if @json_params['project']
      project_id = find_or_create_project @json_params['project']
      attributes[:project_id] = project_id if project_id
    end

    task = todo.create_task(title, **attributes)
    halt 500, { error: 'Failed to create task' }.to_json unless task

    task.to_json
  end

  put '/tasks/:id' do
    id = params['id']
    halt 400, { error: 'Missing task ID' }.to_json if id.nil?

    attributes = {}
    attributes[:title] = @json_params['title'] if @json_params['title']
    attributes[:description] = @json_params['description'] if @json_params['description']
    attributes[:deadline] = @json_params['deadline'] if @json_params['deadline']
    attributes[:done] = parse_done(@json_params['done']) if @json_params.key? 'done'

    task = todo.edit_task(id, **attributes)
    halt 404, { error: 'Task not found' }.to_json unless task

    task.to_json
  end

  post '/projects' do
    name = @json_params['name']
    halt 400, { error: 'Project name is required' }.to_json if name.nil? || name.strip.empty?

    project = todo.create_project name
    halt 500, { error: 'Could not create project' }.to_json unless project

    project.to_json
  end

  get '/project/:name' do
    project = todo.find_project_by_name params['name']
    halt 404, { error: 'Project not found' }.to_json unless project

    project.to_json
  end

  private

  def find_or_create_project(name)
    return nil if name.strip.empty?

    project = todo.find_project_by_name name
    return project.id if project

    created = todo.create_project name
    created&.id
  rescue Todo::TodoError
    nil
  end
end
