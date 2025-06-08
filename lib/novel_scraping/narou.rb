# frozen_string_literal: true

require 'nokogiri'
require 'uri'
require 'active_support'
require 'active_support/time'
require 'novel_scraping/common'

module NovelScraping
  module Narou
    XML_MAIN_TITLE = '//article[@class="p-novel"]/h1[@class="p-novel__title"]'
    XML_SUB_TITLE = 'a[@class="p-eplist__subtitle"]/text()'
    XML_PAGINATION = '//a[@class="c-pager__item c-pager__item--last"]/@href'
    XML_CHAPTER_LIST = '//div[@class="p-eplist__sublist"]'
    XML_CHAPTER_LINK = 'a/@href'
    XML_POST_AT = 'div[@class="p-eplist__update"]/text()'
    XML_EDIT_AT = 'div[@class="p-eplist__update"]/span/@title'
    XML_CONTENT = '//div[@class="p-novel__body"]'

    class << self
      def get_site(url)
        top_html = Nokogiri::HTML(NovelScraping.uri_open(url))
        main_title = top_html.xpath(XML_MAIN_TITLE).text.strip
        htmls = [top_html].tap do |html|
          path = top_html.xpath(XML_PAGINATION)&.first&.value
          if path.present?
            last_page = URI.decode_www_form(URI.parse(path).query).to_h['p'].to_i
            [*2..last_page].each do |page|
              html << Nokogiri::HTML(NovelScraping.uri_open("#{url}/?p=#{page}"))
            end
          end
        end

        chapters = []
        htmls.each do |html|
          html.xpath(XML_CHAPTER_LIST).each do |chapter|
            sub_title = chapter.xpath(XML_SUB_TITLE).text.strip
            next if sub_title.empty?

            chapter_link = URI.join(url, chapter.xpath(XML_CHAPTER_LINK).text)
            post_at = datetime(chapter.xpath(XML_POST_AT).text.gsub(/[\r\n]/, ''))
            edit_at = datetime(chapter.xpath(XML_EDIT_AT).text.gsub(/[\r\n]/, ''))
            chapters << {
              url: chapter_link.to_s,
              sub_title:,
              post_at:,
              edit_at: edit_at.present? ? edit_at : post_at,
              count: chapter_link.to_s.split('/').last.to_i
            }
          end
        end

        [main_title, chapters]
      end

      def get_chapter(url)
        html = Nokogiri::HTML(NovelScraping.uri_open(url))
        html.xpath(XML_CONTENT).inner_html.gsub(/[\r\n]/, '')
      end

      private

      def datetime(string = nil)
        return nil if string.blank?

        match_data = string.match('(\d{4}/\d{2}/\d{2} \d{2}:\d{2})')
        return nil unless match_data && match_data[1]

        begin
          Time.parse(match_data[1])
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
