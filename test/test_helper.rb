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

    def db_config
      @db_config ||= begin
        filepath = File.join('test', 'database.yml')
        YAML.load_file(filepath)['test']
      end
    end

    def establish_connection(config)
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection
    end

    def create_database
      system_config = db_config.merge('database' => 'postgres', 'schema_search_path' => 'public')
      connection = establish_connection(system_config)
      connection.create_database(db_config['database']) rescue nil
    end

    def create_table
      connection = establish_connection(db_config)
      connection.create_table(:posts, :force => true) do |t|
        t.column :title_translations, 'jsonb'
        t.column :body_1_translations, 'jsonb'
        t.column :comment_translations, 'jsonb'
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
