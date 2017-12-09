require "active_record"
require "json_translate/translates"
require "json_translate/translates/instance_methods"

ActiveRecord::Base.extend(JSONTranslate::Translates)
