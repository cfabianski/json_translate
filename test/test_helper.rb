require 'minitest/autorun'
require 'json_translate'

require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

I18n.available_locales = [:en, :fr]

class Post < ActiveRecord::Base
  translates :title, :body_1
end

class PostDetailed < Post
  translates :comment
end

class JSONTranslate::Test < Minitest::Test
  class << self
    def prepare_database
      create_database
      create_table
    end

    private

    def adapter
      @adapter ||= ENV['DB'] || 'postgres'
    end

    def db_config
      @db_config ||= begin
        filepath = File.join('test', 'database.yml')
        YAML.load_file(filepath)[adapter]
      end
    end

    def establish_connection(config)
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection
    end

    def create_database
      system_config = db_config
      connection = establish_connection(system_config)
      connection.create_database(db_config['database']) rescue nil
    end

    def create_table
      column_type = adapter == 'mysql' ? 'json' : 'jsonb'
      connection = establish_connection(db_config)
      connection.create_table(:posts, :force => true) do |t|
        t.column :title_translations, column_type
        t.column :body_1_translations, column_type
        t.column :comment_translations, column_type
      end
    end
  end

  prepare_database

  def setup
    I18n.available_locales = ['en', 'en-US', 'fr']
    I18n.config.enforce_available_locales = true
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end
