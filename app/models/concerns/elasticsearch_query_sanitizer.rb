# frozen_string_literal: true

module ElasticsearchQuerySanitizer
  extend ActiveSupport::Concern

  class_methods do
    def sanitize_elasticsearch_query(query)
      return "" if query.blank?
      # Escape special characters that could be used for injection
      # Special chars: + - = && || > < ! ( ) { } [ ] ^ " ~ * ? : \ /
      sanitized = query.to_s.dup
      dangerous_chars = %w[+ - = & | > < ! ( ) { } [ ] ^ " ~ * ? : \ /].map { |c| Regexp.escape(c) }.join("|")
      sanitized.gsub!(/#{dangerous_chars}/, " ")
      sanitized.gsub!(/\s+/, " ")
      sanitized.strip
    end
  end
end
