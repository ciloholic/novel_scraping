# frozen_string_literal: true

require 'novel_scraping/version'
require 'novel_scraping/base_scraper'
require 'novel_scraping/date_time_parser'
require 'novel_scraping/arcadia'
require 'novel_scraping/narou'
require 'novel_scraping/hameln'
require 'novel_scraping/akatsuki'
require 'novel_scraping/nocturne'

module NovelScraping
  class << self
    attr_writer :logger, :verbose

    def logger
      formatter = proc { |_severity, datetime, _progname, msg| "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{msg}\n" }
      @logger ||=
        (defined?(Rails) ? Rails.logger : ActiveSupport::Logger.new($stdout)).tap do |log|
          log.formatter = formatter
        end
    end

    def verbose
      @verbose.nil? || @verbose
    end

    def access(url, from: nil)
      host = URI.parse(url).host
      scraper = NovelScraping.const_get(module_name[host])
      logger.info("Start scraping with #{scraper}") if verbose
      main_title, chapters = scraper.get_site(url)
      logger.info("Found #{chapters.size} chapters in \"#{main_title}\"") if verbose
      if from
        from = Time.parse(from) if from.instance_of?(String)
        chapters = chapters.select { |chapter| from <= chapter[:edit_at] }
        logger.info("Filtered to #{chapters.size} chapters") if verbose
      end
      chapters.each.with_index(1) do |chapter, index|
        logger.info("Fetching chapter (#{index}/#{chapters.size}): #{chapter[:sub_title]}") if verbose
        chapter[:content] = scraper.get_chapter(chapter[:url])
      end
      logger.info('Scraping completed') if verbose
      [main_title, chapters]
    end
  end
end
