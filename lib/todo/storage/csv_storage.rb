class Todo
  module Storage
    class CSVStorage
      def initialize(file = 'tasks.csv')
        @file = file
        # puts 'true'
      end

      def read
        tasks = []

        CSV.foreach @file, headers: true, header_converters: :symbol do |row|
          task = row.to_h
          task[:done] = task[:done] == 'true' if task.key? :done
          tasks << task
        end

        tasks
      rescue Errno::ENOENT
        raise TodoFileReadError, "File not found: #{@file}"
      rescue Errno::EACCES
        raise TodoFileReadError, "Permission denied to read file: #{@file}"
      rescue CSV::MalformedCSVError
        raise TodoFileReadError, "Malformed csv: #{@file}"
      rescue StandardError => e
        raise TodoFileReadError, "Unexpected error: #{e.message}"
      end

      def write(tasks)
        headers = tasks.first&.keys
        return if headers.nil?

        CSV.open @file, 'w', write_headers: true, headers: headers do |csv|
          tasks.each do |task|
            csv << headers.map { |header| task[header] }
          end
        end
      rescue Errno::ENOENT
        raise TodoFileWriteError, "File not found: #{@file}"
      rescue Errno::EACCES
        raise TodoFileWriteError, "Permission denied to write file: #{@file}"
      rescue StandardError => e
        raise TodoFileWriteError, "Unexpected error: #{e.message}"
      end
    end
  end
end
