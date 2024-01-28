# frozen_string_literal: true

require 'nokogiri'
require 'uri'
require 'open-uri'
require 'rack'
require 'active_support'
require 'active_support/time'
require 'novel_scraping/common'

module NovelScraping
  module Nocturne
    XML_MAIN_TITLE = '//*[@id="novel_color"]/p[@class="novel_title"]'
    XML_SUB_TITLE = 'dd[@class="subtitle"]/a'
    XML_PAGINATION = '//*[@class="novelview_pager-last"]/@href'
    XML_CHAPTER_LIST = '//*[@id="novel_color"]/div[@class="index_box"]/dl[@class="novel_sublist2"]'
    XML_CHAPTER_LINK = 'dd[@class="subtitle"]/a/@href'
    XML_POST_AT = 'dt[@class="long_update"]/text()'
    XML_EDIT_AT = 'dt[@class="long_update"]/span/@title'
    XML_CONTENT = '//*[@id="novel_honbun"]'

    class << self
      def get_site(url)
        top_html = Nokogiri::HTML(NovelScraping.uri_open(url, { 'Cookie' => 'over18=yes' }))
        main_title = top_html.xpath(XML_MAIN_TITLE).text

        htmls = [top_html].tap do |html|
          path = top_html.xpath(XML_PAGINATION)&.first&.value
          if path.present?
            last_page = URI.decode_www_form(URI.parse(path).query).to_h['p'].to_i
            [*2..last_page].each do |page|
              html << Nokogiri::HTML(NovelScraping.uri_open("#{url}/?p=#{page}", { 'Cookie' => 'over18=yes' }))
            end
          end
        end

        chapters = []
        htmls.each do |html|
          html.xpath(XML_CHAPTER_LIST).each do |chapter|
            next if chapter.xpath(XML_SUB_TITLE).text.empty?

            chapter_link = URI.join(url, chapter.xpath(XML_CHAPTER_LINK).text)
            post_at = datetime(chapter.xpath(XML_POST_AT).text.gsub(/[\r\n]/, ''))
            edit_at = datetime(chapter.xpath(XML_EDIT_AT).text.gsub(/[\r\n]/, ''))
            chapters << {
              url: chapter_link.to_s,
              sub_title: chapter.xpath(XML_SUB_TITLE).text,
              post_at:,
              edit_at: edit_at.present? ? edit_at : post_at,
              count: chapter_link.to_s.split('/').last.to_i
            }
          end
        end

        [main_title, chapters]
      end

      def get_chapter(url)
        html = Nokogiri::HTML(NovelScraping.uri_open(url, { 'Cookie' => 'over18=yes' }))
        html.xpath(XML_CONTENT).inner_html.gsub(/[\r\n]/, '')
      end

      private

      def datetime(string = nil)
        return nil if string.blank?

        Time.parse(string.match('(\d{4}/\d{2}/\d{2} \d{2}:\d{2})')[1])
      end
    end
  end
end
