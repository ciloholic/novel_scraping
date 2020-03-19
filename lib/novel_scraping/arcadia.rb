# frozen_string_literal: true

require 'nokogiri'
require 'uri'
require 'open-uri'
require 'rack'
require 'active_support'
require 'active_support/time'
require 'novel_scraping/common'

module NovelScraping
  module Arcadia
    XML_MAIN_TITLE = '//*[@id="table"]/tr[1]/td[2]/b/a'
    XML_SUB_TITLE = 'td[2]/b/a'
    XML_CHAPTER_LIST = '//*[@id="table"]/tr'
    XML_CHAPTER_LINK = 'td[2]/b/a/@href'
    XML_POST_AT = 'td[4]'
    XML_EDIT_AT = 'td[4]'
    XML_CONTENT = '//blockquote/div'

    class << self
      def get_site(url)
        html = Nokogiri::HTML(NovelScraping.kernel_open(url))
        main_title = html.xpath(XML_MAIN_TITLE).text
        chapters = []
        html.xpath(XML_CHAPTER_LIST).each do |chapter|
          next if chapter.xpath(XML_SUB_TITLE).text.empty?

          chapter_link = URI.join(url, chapter.xpath(XML_CHAPTER_LINK).text)
          post_at = datetime(chapter.xpath(XML_POST_AT).text.gsub(/[()]/, ''))
          edit_at = datetime(chapter.xpath(XML_EDIT_AT).text.gsub(/[()]/, ''))
          chapters << {
            url: chapter_link.to_s,
            sub_title: chapter.xpath(XML_SUB_TITLE).text,
            post_at: post_at,
            edit_at: edit_at.present? ? edit_at : post_at,
            count: Rack::Utils.parse_nested_query(chapter_link.query)['n'].to_i
          }
        end
        [main_title, chapters]
      end

      def get_chapter(url)
        html = Nokogiri::HTML(NovelScraping.kernel_open(url))
        html.xpath(XML_CONTENT).inner_html.gsub(/[\r\n]/, '')
      end

      private

      def datetime(string)
        return nil if string.blank?

        Time.parse(string.match('(\d{4}/\d{2}/\d{2} \d{2}:\d{2})')[1])
      end
    end
  end
end
