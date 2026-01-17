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
    def random_sleep(min: 1, max: 4)
      sleep(rand(min..max))
    end

    def uri_open(url, option = {})
      random_sleep
      res = Faraday.get(url) do |req|
        req.headers['User-Agent'] = Faker::Internet.user_agent
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
