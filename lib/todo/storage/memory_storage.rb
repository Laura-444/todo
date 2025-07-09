class Todo
  module Storage
    class MemoryStorage
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
  end
end
