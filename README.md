[![Gem Version](https://badge.fury.io/rb/json_translate.svg)](https://badge.fury.io/rb/json_translate)
[![Build Status](https://api.travis-ci.org/cfabianski/json_translate.png)](https://travis-ci.org/cfabianski/json_translate)
[![License](http://img.shields.io/badge/license-mit-brightgreen.svg)](COPYRIGHT)
[![Code Climate](https://codeclimate.com/github/cfabianski/json_translate.png)](https://codeclimate.com/github/cfabianski/json_translate)

# JSON Translate

Rails I18n library for ActiveRecord model/data translation using PostgreSQL's
JSONB datatype or MySQL's JSON datatype. It provides an interface inspired by
[Globalize3](https://github.com/svenfuchs/globalize3) but removes the need to
maintain separate translation tables.

## Requirements

* ActiveRecord >= 4.2.0
* I18n
* MySQL support requires ActiveRecord >= 5 and MySQL >= 5.7.8.

## Installation

gem install json_translate

When using bundler, put it in your Gemfile:

```ruby
source 'https://rubygems.org'

gem 'activerecord'

# PostgreSQL
gem 'pg', :platform => :ruby
gem 'activerecord-jdbcpostgresql-adapter', :platform => :jruby

# or MySQL
gem 'mysql2', :platform => :ruby
gem 'activerecord-jdbcmysql-adapter', :platform => :jruby

gem 'json_translate'
```

## Model translations

Model translations allow you to translate your models' attribute values. E.g.

```ruby
class Post < ActiveRecord::Base
  translates :title, :body
end
```

Allows you to translate the attributes :title and :body per locale:

```ruby
I18n.locale = :en
post.title # => This database rocks!

I18n.locale = :he
post.title # => אתר זה טוב
```

You also have locale-specific convenience methods from [easy_globalize3_accessors](https://github.com/paneq/easy_globalize3_accessors):

```ruby
I18n.locale = :en
post.title # => This database rocks!
post.title_he # => אתר זה טוב
```

To find records using translations without constructing JSON queries by hand:

```ruby
Post.with_title_translation("This database rocks!") # => #<ActiveRecord::Relation ...>
Post.with_title_translation("אתר זה טוב", :he) # => #<ActiveRecord::Relation ...>
```

In order to make this work, you'll need to define an JSON or JSONB column for each of
your translated attributes, using the suffix "_translations":

```ruby
class CreatePosts < ActiveRecord::Migration
  def up
    create_table :posts do |t|
      t.column :title_translations, 'jsonb' # or 'json' for MySQL
      t.column :body_translations,  'jsonb'
      t.timestamps
    end
  end
  def down
    drop_table :posts
  end
end
```

## I18n fallbacks for missing translations

It is possible to enable fallbacks for missing translations. It will depend
on the configuration setting you have set for I18n translations in your Rails
config.

You can enable them by adding the next line to `config/application.rb` (or
only `config/environments/production.rb` if you only want them in production)

```ruby
config.i18n.fallbacks = true
```
Sven Fuchs wrote a [detailed explanation of the fallback
mechanism](https://github.com/svenfuchs/i18n/wiki/Fallbacks).

## I18n fallbacks for empty translations
It is possible to enable fallbacks for missing translations. 
By default, JSON_translate will only use fallbacks when your translation 
JSON column does not exist or the translation value for the item you've request is nil.
However it is possible to use fallbacks for empty translations by adding 
`:fallbacks_for_empty_translations => true` to the `translates` method

```ruby
class Post < ActiveRecord::Base
  translates :title, :name, :fallbacks_for_empty_translations => true
end

puts post.inspect
# => <PostDetailed id: 1, title_translations: {"en"=>"This database rocks", "nl"=>""}, name: {"en"=>"PostgreSQL", "nl"=>""}>

I18n.locale = :en
post.title # => 'This database rocks!'
post.name  # => 'PostgreSQL'

I18n.locale = :nl
post.title # => 'This database rocks!'
post.name  # => 'PostgreSQL'
```

## Temporarily disable fallbacks

If you've enabled fallbacks for missing translations, you probably want to disable
them in the admin interface to display which translations the user still has to
fill in.

From:

```ruby
I18n.locale = :en
post.title # => This database rocks!
post.title_nl # => This database rocks!
```

To:

```ruby
I18n.locale = :en
post.title # => This database rocks!
post.disable_fallback
post.title_nl # => nil
```

You can also call your code into a block that temporarily disable or enable fallbacks.

```ruby
I18n.locale = :en
post.title_nl # => This database rocks!

post.disable_fallback do
  post.title_nl # => nil
end

post.disable_fallback
post.enable_fallback do
  post.title_nl # => This database rocks!
end
```
