module JSONTranslate
  module Translates
    SUFFIX = "_translations".freeze
    MYSQL_ADAPTERS = %w[MySQL Mysql2 Mysql2Spatial]


    def translates(*attrs)
      include InstanceMethods

      class_attribute :translated_attribute_names, :permitted_translated_attributes

      self.translated_attribute_names = attrs
      self.permitted_translated_attributes = [
        *self.ancestors
          .select {|klass| klass.respond_to?(:permitted_translated_attributes) }
          .map(&:permitted_translated_attributes),
        *attrs.product(I18n.available_locales)
          .map { |attribute, locale| :"#{attribute}_#{locale}" }
      ].flatten.compact

      attrs.each do |attr_name|
        define_method attr_name do
          read_json_translation(attr_name)
        end

        define_method "#{attr_name}=" do |value|
          write_json_translation(attr_name, value)
        end

        define_singleton_method "with_#{attr_name}_translation" do |value, locale = I18n.locale|
          quoted_translation_store = connection.quote_column_name("#{attr_name}#{SUFFIX}")
          translation_hash = { "#{locale}" => value }

          if MYSQL_ADAPTERS.include?(connection.adapter_name)
            where("JSON_CONTAINS(#{quoted_translation_store}, :translation, '$')", translation: translation_hash.to_json)
          else
            where("#{quoted_translation_store} @> :translation::jsonb", translation: translation_hash.to_json)
          end
        end
      end

      send(:prepend, ActiveRecordWithJSONTranslate)
    end

    def translates?
      included_modules.include?(InstanceMethods)
    end
  end
end
