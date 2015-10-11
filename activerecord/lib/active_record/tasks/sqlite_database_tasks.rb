module ActiveRecord
  module Tasks # :nodoc:
    class SQLiteDatabaseTasks # :nodoc:
      def initialize(configuration, root = ActiveRecord::Tasks::DatabaseTasks.root)
        @configuration, @root = configuration, root
      end

      def create
        raise DatabaseAlreadyExists if configuration['file_system_interactor'].exist?(configuration['database'])

        configuration['database_interactor'].establish_connection configuration
        configuration['database_interactor'].connection
      end

      def drop
        require 'pathname'
        path = Pathname.new configuration['database']
        file = path.absolute? ? path.to_s : File.join(root, path)

        FileUtils.rm(file) if configuration['file_system_interactor'].exist?(file)
      end

      def purge
        drop
        create
      end

      def charset
        connection['database_interactor'].connection.encoding
      end

      def structure_dump(filename)
        dbfile = configuration['database']
        `sqlite3 #{dbfile} .schema > #{filename}`
      end

      def structure_load(filename)
        dbfile = configuration['database']
        `sqlite3 #{dbfile} < "#{filename}"`
      end

      private

      def configuration
        @configuration
      end

      def root
        @root
      end
    end
  end
end
