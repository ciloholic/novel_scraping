# frozen_string_literal: true

require 'faraday'

module NovelScraping
  class HttpError < StandardError
    attr_reader :status

    def initialize(status)
      @status = status
      super("HTTP Request Failed: #{status}")
    end
  end

  MODULE_NAME_MAP = {
    'www.mai-net.net' => 'Arcadia',
    'ncode.syosetu.com' => 'Narou',
    'syosetu.org' => 'Hameln',
    'www.akatsuki-novels.com' => 'Akatsuki',
    'novel18.syosetu.com' => 'Nocturne'
  }.freeze

  class << self
    def random_sleep(min: 3, max: 7)
      sleep(rand(min..max))
    end

    def uri_open(url, option = {})
      random_sleep
      logger.info("GET #{url}") if verbose
      cdp_url ? fetch_with_cdp(url, option) : fetch_with_faraday(url, option)
    end

    def module_name
      MODULE_NAME_MAP
    end

    private

    def fetch_with_faraday(url, option)
      res = Faraday.get(url) do |req|
        req.headers['User-Agent'] = option[:user_agent] || Faker::Internet.user_agent
        req.headers['Cookie'] = option[:cookie] if option.key?(:cookie)
        req.headers['Referer'] = option[:referer] if option.key?(:referer)
      end
      raise_http_error(res.status, url) unless res.success?

      res.body
    rescue Faraday::Error => e
      logger.error("Faraday Error: #{e.message} #{url}") if verbose
      raise "Faraday Error: #{e.message}"
    end

    # Fetch the page through a running Chrome connected via CDP.
    # User-Agent and Referer are not overridden so that the browser's own values are used.
    def fetch_with_cdp(url, option)
      require 'ferrum'

      browser = Ferrum::Browser.new(url: cdp_url)
      begin
        page = browser.create_page
        set_cdp_cookie(page, url, option[:cookie]) if option.key?(:cookie)
        page.go_to(url)
        status = page.network.status
        raise_http_error(status, url) unless (200..299).cover?(status)

        page.body
      ensure
        page&.close
        browser.quit
      end
    rescue Ferrum::Error => e
      logger.error("Ferrum Error: #{e.message} #{url}") if verbose
      raise "Ferrum Error: #{e.message}"
    end

    def set_cdp_cookie(page, url, cookie)
      name, value = cookie.split('=', 2)
      page.cookies.set(name:, value:, domain: URI.parse(url).host)
    end

    def raise_http_error(status, url)
      logger.error("HTTP Request Failed: #{status} #{url}") if verbose
      raise HttpError, status
    end
  end
end
