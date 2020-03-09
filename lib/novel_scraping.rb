# frozen_string_literal: true

require 'novel_scraping/version'
require 'novel_scraping/arcadia'
require 'novel_scraping/narou'
require 'novel_scraping/hameln'
require 'novel_scraping/akatsuki'
require 'novel_scraping/nocturne'

module NovelScraping
  class << self
    def access(url)
      case URI.parse(url).host
      when 'www.mai-net.net'
        main_title, chapters = NovelScraping::Arcadia.get_site(url)
        chapters.each do |chapter|
          chapter[:content] = NovelScraping::Arcadia.get_chapter(chapter[:url])
        end
      when 'ncode.syosetu.com'
        main_title, chapters = NovelScraping::Narou.get_site(url)
        chapters.each do |chapter|
          chapter[:content] = NovelScraping::Narou.get_chapter(chapter[:url])
        end
      when 'syosetu.org'
        main_title, chapters = NovelScraping::Hameln.get_site(url)
        chapters.each do |chapter|
          chapter[:content] = NovelScraping::Hameln.get_chapter(chapter[:url])
        end
      when 'www.akatsuki-novels.com'
        main_title, chapters = NovelScraping::Akatsuki.get_site(url)
        chapters.each do |chapter|
          chapter[:content] = NovelScraping::Akatsuki.get_chapter(chapter[:url])
        end
      when 'novel18.syosetu.com'
        main_title, chapters = NovelScraping::Nocturne.get_site(url)
        chapters.each do |chapter|
          chapter[:content] = NovelScraping::Nocturne.get_chapter(chapter[:url])
        end
      end
      [main_title, chapters]
    end
  end
end
