# frozen_string_literal: true

require 'nokogiri'

module NovelScraping
  class BaseScraper
    class << self
      def get_chapter(url)
        html = Nokogiri::HTML(NovelScraping.uri_open(url, request_options))
        html.xpath(self::XML_CONTENT).inner_html.gsub(/[\r\n]/, '')
      end

      private

      def request_options
        {}
      end
    end
  end
end
