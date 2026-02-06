# frozen_string_literal: true

require 'active_support'
require 'active_support/time'
require 'faker'
require 'nokogiri'
require 'novel_scraping/common'
require 'rack'
require 'uri'

module NovelScraping
  class Arcadia < BaseScraper
    XML_MAIN_TITLE = '//*[@id="table"]/tr[1]/td[2]/b/a'
    XML_SUB_TITLE = 'td[2]/b/a'
    XML_CHAPTER_LIST = '//*[@id="table"]/tr'
    XML_CHAPTER_LINK = 'td[2]/b/a/@href'
    XML_POST_AT = 'td[4]'
    XML_EDIT_AT = 'td[4]'
    XML_CONTENT = '//blockquote/div'

    class << self
      def get_site(url)
        html = Nokogiri::HTML(NovelScraping.uri_open(url))
        main_title = html.xpath(XML_MAIN_TITLE).text.strip

        chapters = []
        html.xpath(XML_CHAPTER_LIST).each do |chapter|
          sub_title = chapter.xpath(XML_SUB_TITLE).text.strip
          next if sub_title.empty?

          chapter_link = URI.join(url, chapter.xpath(XML_CHAPTER_LINK).text)
          post_at = datetime(chapter.xpath(XML_POST_AT).text.gsub(/[()]/, ''))
          edit_at = datetime(chapter.xpath(XML_EDIT_AT).text.gsub(/[()]/, ''))
          chapters << {
            url: chapter_link.to_s,
            sub_title:,
            post_at:,
            edit_at: edit_at.present? ? edit_at : post_at,
            count: Rack::Utils.parse_nested_query(chapter_link.query.to_s)['n'].to_i
          }
        end

        [main_title, chapters]
      end

      private

      def datetime(string = nil)
        DateTimeParser.parse(string, :slash_format)
      end
    end
  end
end
