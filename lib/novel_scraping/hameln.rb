# frozen_string_literal: true

require 'nokogiri'
require 'uri'
require 'open-uri'
require 'rack'
require 'active_support'
require 'active_support/time'
require 'novel_scraping/common'

module NovelScraping
  module Hameln
    XML_MAIN_TITLE = '//*[@id="maind"]/div[1]/span[1]'
    XML_SUB_TITLE = 'td[1]/a'
    XML_CHAPTER_LIST = '//*[@id="maind"]/div[3]/table/tr'
    XML_CHAPTER_LINK = 'td[1]/a/@href'
    XML_POST_AT1 = 'td[2]/nobr/text()'
    XML_POST_AT2 = 'td[2]/nobr/time/text()'
    XML_EDIT_AT = 'td[2]/nobr/span/@title'
    XML_CONTENT = '//*[@id="honbun"]'

    class << self
      def get_site(url)
        html = Nokogiri::HTML(NovelScraping.kernel_open(url))
        main_title = html.xpath(XML_MAIN_TITLE).text
        chapters = []
        html.xpath(XML_CHAPTER_LIST).each do |chapter|
          next if chapter.xpath(XML_SUB_TITLE).text.empty?

          chapter_link = URI.join(url, chapter.xpath(XML_CHAPTER_LINK).text)
          post_at = datetime(chapter.xpath(XML_POST_AT1).text.gsub(/\(.\)/, ''))
          post_at = datetime(chapter.xpath(XML_POST_AT2).text.gsub(/\(.\)/, '')) unless post_at.present?
          edit_at = datetime(chapter.xpath(XML_EDIT_AT).text.gsub(/\(.\)/, ''))
          chapters << {
            url: chapter_link.to_s,
            sub_title: chapter.xpath(XML_SUB_TITLE).text,
            post_at: post_at,
            edit_at: edit_at.present? ? edit_at : post_at,
            count: chapter_link.to_s.split('/').last.to_i
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

        Time.strptime(string, '%Y年%m月%d日 %H:%M').strftime('%Y/%m/%d %H:%M:%S')
      end
    end
  end
end
