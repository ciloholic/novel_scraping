# frozen_string_literal: true

require 'active_support'
require 'active_support/time'
require 'faker'
require 'nokogiri'
require 'novel_scraping/common'
require 'uri'

module NovelScraping
  class Akatsuki < BaseScraper
    XML_MAIN_TITLE = '//*[@id="LookNovel"]'
    XML_SUB_TITLE = 'td[1]/a'
    XML_CHAPTER_LIST = '//table[@class="list"]/tbody/tr'
    XML_CHAPTER_LINK = 'td/a/@href'
    XML_POST_AT = 'td[2]'
    XML_EDIT_AT = 'td[2]'
    XML_CONTENT = '//div[@class="body-novel"]'

    class << self
      def get_site(url)
        html = Nokogiri::HTML(NovelScraping.uri_open(url))
        main_title = html.xpath(XML_MAIN_TITLE).text.strip

        chapters = []
        html.xpath(XML_CHAPTER_LIST).each do |chapter|
          sub_title = chapter.xpath(XML_SUB_TITLE).text.strip
          next if sub_title.empty?

          chapter_link = URI.join(url, chapter.xpath(XML_CHAPTER_LINK).text)
          post_at = datetime(chapter.xpath(XML_POST_AT).text.gsub(/ |\u00a0/, ''))
          chapters << {
            url: chapter_link.to_s,
            sub_title:,
            post_at:,
            edit_at: post_at,
            count: chapter_link.to_s.match(%r{/stories/view/(\d+)})&.captures&.first.to_i
          }
        end

        [main_title, chapters]
      end

      private

      def datetime(string = nil)
        DateTimeParser.parse(string, :japanese_full)
      end
    end
  end
end
