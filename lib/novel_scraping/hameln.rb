# frozen_string_literal: true

require 'active_support'
require 'active_support/time'
require 'faker'
require 'nokogiri'
require 'novel_scraping/common'
require 'open-uri'
require 'rack'
require 'uri'

module NovelScraping
  class Hameln < BaseScraper
    XML_MAIN_TITLE = '//*[@id="maind"]/div[1]/span[1]'
    XML_SUB_TITLE = 'a/span[@class="episode-list__title"]'
    XML_CHAPTER_LIST = '//*[@id="maind"]//section[@class="episode-list"]//li[@class="episode-list__item"]'
    XML_CHAPTER_LINK = 'a/@href'
    XML_POST_AT = 'a/time[@class="episode-list__date"]/text()'
    XML_EDIT_AT = 'a/span[@class="episode-list__revision"]/@title'
    XML_CONTENT = '//*[@id="honbun"]'

    class << self
      def get_site(url)
        html = Nokogiri::HTML(NovelScraping.uri_open(url, { cookie: 'over18=off', user_agent: }))
        main_title = html.xpath(XML_MAIN_TITLE).text.strip

        chapters = []
        html.xpath(XML_CHAPTER_LIST).each do |chapter|
          sub_title = chapter.xpath(XML_SUB_TITLE).text.strip
          next if sub_title.empty?

          chapter_link = URI.join(url, chapter.xpath(XML_CHAPTER_LINK).text)
          post_at = datetime(chapter.xpath(XML_POST_AT).text)
          edit_at = datetime(chapter.xpath(XML_EDIT_AT).text)
          chapters << {
            url: chapter_link.to_s,
            sub_title:,
            post_at:,
            edit_at: edit_at.present? ? edit_at : post_at,
            count: chapter_link.to_s.split('/').last.to_i
          }
        end

        [main_title, chapters]
      end

      private

      def request_options
        { cookie: 'over18=off' }
      end

      def datetime(string = nil)
        DateTimeParser.parse(string, :slash_format)
      end
    end
  end
end
