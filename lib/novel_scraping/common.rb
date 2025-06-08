# frozen_string_literal: true

require 'faraday'

module NovelScraping
  USER_AGENTS = [
    'Mozilla/5.0 (iPad; CPU OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/605.1.15',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/605.1.15',
    'Mozilla/5.0 (Linux; Android 12; Pixel 6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 13; SM-S911B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 11_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Safari/605.1.15',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 12_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.4 Safari/605.1.15',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:115.0) Gecko/20100101 Firefox/115.0',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko'
  ].freeze

  MODULE_NAME_MAP = {
    'www.mai-net.net' => 'Arcadia',
    'ncode.syosetu.com' => 'Narou',
    'syosetu.org' => 'Hameln',
    'www.akatsuki-novels.com' => 'Akatsuki',
    'novel18.syosetu.com' => 'Nocturne'
  }.freeze

  class << self
    def user_agent
      USER_AGENTS.sample
    end

    def random_sleep(min: 1, max: 4)
      sleep(rand(min..max))
    end

    def uri_open(url, option = {})
      random_sleep
      res = Faraday.get(url) do |req|
        req.headers['User-Agent'] = user_agent
        req.headers['Cookie'] = option[:cookie] if option.key?(:cookie)
      end
      raise "HTTP Request Failed: #{res.status}" unless res.success?

      res.body
    rescue Faraday::Error => e
      raise "Faraday Error: #{e.message}"
    end

    def module_name
      MODULE_NAME_MAP
    end
  end
end
