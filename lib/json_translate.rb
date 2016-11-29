require "active_record"
require "json_translate/translates"
require "json_translate/translates/instance_methods"
require "json_translate/translates/active_record_with_json_translates"

ActiveRecord::Base.extend(JSONTranslate::Translates)
