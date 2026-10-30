# frozen_string_literal: true

require 'faraday'
require 'resolv'
require 'uri'

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

  CDP_TIMEOUT = 30
  IP_ADDRESS_REGEXP = /\A#{Resolv::AddressRegex}\z/

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

    def fetch_with_cdp(url, option)
      require 'ferrum'

      browser = Ferrum::Browser.new(url: cdp_endpoint, timeout: CDP_TIMEOUT)
      begin
        target_id = browser.command('Target.createTarget', url: 'about:blank', background: true)['targetId']
        page = wait_for_cdp_target(browser.default_context, target_id).page
        set_cdp_cookie(page, url, option[:cookie]) if option.key?(:cookie)
        page.go_to(url)
        status = page.network.status
        raise_http_error(status, url) unless (200..299).cover?(status)

        page.body
      ensure
        close_cdp_tab(browser, target_id, page)
        browser.quit
      end
    rescue Ferrum::Error => e
      logger.error("Ferrum Error: #{e.message} #{url}") if verbose
      raise "Ferrum Error: #{e.message}"
    end

    def wait_for_cdp_target(context, target_id)
      deadline = Time.now + CDP_TIMEOUT
      until (target = context.targets[target_id])
        raise Ferrum::TimeoutError if Time.now >= deadline

        sleep 0.1
      end
      target
    end

    def close_cdp_tab(browser, target_id, page)
      if page
        page.close
      elsif target_id
        browser.command('Target.closeTarget', targetId: target_id)
      end
    end

    # Chrome rejects DevTools requests whose Host header is neither an IP address nor localhost
    def cdp_endpoint
      uri = URI.parse(cdp_url)
      return cdp_url if uri.hostname == 'localhost' || uri.hostname.match?(IP_ADDRESS_REGEXP)

      uri.hostname = Resolv.getaddress(uri.hostname)
      uri.to_s
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
