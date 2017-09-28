module JSONTranslate
  module Translates
    module ActiveRecordWithJSONTranslate
      def respond_to?(symbol, include_all = false)
        return true if parse_translated_attribute_accessor(symbol)
        super(symbol, include_all)
      end

      def method_missing(method_name, *args, **params)
        translated_attr_name, locale, assigning = parse_translated_attribute_accessor(method_name)

        return super(method_name, *args, **params) unless translated_attr_name

        if assigning
          write_json_translation(translated_attr_name, args.first, locale)
        else
          read_json_translation(translated_attr_name, locale, **params)
        end
      end
    end
  end
end
