# frozen_string_literal: true

require 'faker'
require 'nokogiri'

module NovelScraping
  class BaseScraper
    class << self
      def get_chapter(url, referer: nil)
        options = request_options.merge(user_agent:).merge(referer ? { referer: } : {})
        html = Nokogiri::HTML(NovelScraping.uri_open(url, options))
        html.xpath(self::XML_CONTENT).inner_html.gsub(/[\r\n]/, '')
      end

      private

      def user_agent
        @user_agent ||= Faker::Internet.user_agent
      end

      def request_options
        {}
      end
    end
  end
end
