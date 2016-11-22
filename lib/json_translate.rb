require 'active_record'
require 'json_translate/translates'

ActiveRecord::Base.extend(JSONTranslate::Translates)
