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
      host = URI.parse(url).host
      main_title, chapters = NovelScraping.const_get(module_name[host]).get_site(url)
      chapters.each do |chapter|
        chapter[:content] = NovelScraping.const_get(module_name[host]).get_chapter(chapter[:url])
      end
      [main_title, chapters]
    end
  end
end
