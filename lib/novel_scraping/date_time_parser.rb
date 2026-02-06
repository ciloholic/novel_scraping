# frozen_string_literal: true

require 'time'

module NovelScraping
  module DateTimeParser
    # Supported formats:
    # - :slash_format   - for Narou/Nocturne/Arcadia (YYYY/MM/DD HH:MM)
    # - :japanese_space - for Hameln (YYYY年MM月DD日 HH:MM)
    # - :japanese_full  - for Akatsuki (YYYY年MM月DD日HH時MM分)
    FORMATS = {
      slash_format: {
        pattern: %r{(\d{4}/\d{2}/\d{2} \d{2}:\d{2})},
        parser: ->(str) { Time.parse(str) }
      },
      japanese_space: {
        pattern: nil,
        parser: ->(str) { Time.strptime(str, '%Y年%m月%d日 %H:%M') }
      },
      japanese_full: {
        pattern: nil,
        parser: ->(str) { Time.strptime(str, '%Y年%m月%d日%H時%M分') }
      }
    }.freeze

    class << self
      def parse(string, format)
        return nil if string.nil? || string.empty?

        config = FORMATS[format]
        return nil unless config

        target = extract_target(string, config[:pattern])
        return nil unless target

        config[:parser].call(target)
      rescue ArgumentError
        nil
      end

      private

      def extract_target(string, pattern)
        return string unless pattern

        match_data = string.match(pattern)
        match_data&.[](1)
      end
    end
  end
end
