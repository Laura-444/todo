class Todo
  module Storage
    class JSONStorage
      def initialize(file)
        @file = file
      end

      def read
        content_file = File.read @file
        JSON.parse(content_file, { symbolize_names: true })
      rescue Errno::ENOENT
        raise TodoFileReadError, "File not found: #{@file}"
      rescue Errno::EACCES
        raise TodoFileReadError, "Permission denied to read file: #{@file}"
      rescue JSON::ParserError
        raise TodoFileReadError, "Malformed json: #{@file}"
      rescue StandardError => e
        raise TodoFileReadError, "Unexpected error: #{e.message}"
      end

      def write(tasks)
        JSON.dump tasks, File.open(@file, 'w')
        # File.write @file, JSON.pretty_generate(tasks)
      rescue Errno::EACCES
        raise TodoFileWriteError, "Permission denied to write file: #{@file}"
      rescue Errno::ENOENT
        raise TodoFileWriteError, "File not found: #{@file} "
      rescue StandardError => e
        raise TodoFileWriteError, "Unexpected error: #{e.message}"
      end
    end
  end
end
