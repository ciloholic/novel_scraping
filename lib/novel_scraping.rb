# frozen_string_literal: true

require 'novel_scraping/version'
require 'novel_scraping/arcadia'
require 'novel_scraping/Narou'

module NovelScraping
  class << self
    def access(url)
      case URI.parse(url).host
      when 'www.mai-net.net' # arcadia
        main_title, chapters = NovelScraping::Arcadia.get_site(url)
        chapters.each do |chapter|
          chapter[:content] = NovelScraping::Arcadia.get_chapter(chapter[:url])
        end
      when 'ncode.syosetu.com' # narou
        main_title, chapters = NovelScraping::Narou.get_site(url)
        p main_title
        p chapters
      when 'syosetu.org' # hameln
      when 'www.akatsuki-novels.com' # akatsuki
      when 'novel18.syosetu.com' # nocturne
      end
    end
  end
end
