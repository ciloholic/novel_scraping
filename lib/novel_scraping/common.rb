# frozen_string_literal: true

require 'faraday'

module NovelScraping
  MODULE_NAME_MAP = {
    'www.mai-net.net' => 'Arcadia',
    'ncode.syosetu.com' => 'Narou',
    'syosetu.org' => 'Hameln',
    'www.akatsuki-novels.com' => 'Akatsuki',
    'novel18.syosetu.com' => 'Nocturne'
  }.freeze

  class << self
    def random_sleep(min: 3, max: 10)
      sleep(rand(min..max))
    end

    def uri_open(url, option = {})
      random_sleep
      logger.info("GET #{url}") if verbose
      res = Faraday.get(url) do |req|
        req.headers['User-Agent'] = Faker::Internet.user_agent
        req.headers['Cookie'] = option[:cookie] if option.key?(:cookie)
        req.headers['Referer'] = option[:referer] if option.key?(:referer)
      end
      unless res.success?
        logger.error("HTTP Request Failed: #{res.status} #{url}") if verbose
        raise "HTTP Request Failed: #{res.status}"
      end

      res.body
    rescue Faraday::Error => e
      logger.error("Faraday Error: #{e.message} #{url}") if verbose
      raise "Faraday Error: #{e.message}"
    end

    def module_name
      MODULE_NAME_MAP
    end
  end
end
