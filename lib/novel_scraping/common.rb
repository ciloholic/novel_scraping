# frozen_string_literal: true

module NovelScraping
  class << self
    def user_agent
      [
        'Mozilla/5.0 (iPad; U; CPU OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3',
        'Mozilla/5.0 (iPhone; CPU iPhone OS 14_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) GSA/162.0.375868988 Mobile/15E148 Safari/604.1',
        'Mozilla/5.0 (Linux; Android 4.4.2; SO-03F Build/17.1.1.B.3.195) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.81 Mobile Safari/537.36',
        'Mozilla/5.0 (Macintosh; ARM Mac OS X) AppleWebKit/538.15 (KHTML, like Gecko) Safari/538.15 Version/6.0 Raspbian/8.0',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit / 537.36(KHTML, like Gecko) Chrome / 73.0.3683.75 Safari / 537.36',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:99.0) Gecko/20100101 Firefox/99.8',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4356.6 Safari/537.36'
      ].sample
    end

    def random_sleep(min: 1, max: 4)
      sleep([*min..max].sample)
    end

    def uri_open(url, option = nil)
      options = { 'User-Agent' => user_agent }
      options.merge!(option) unless option.nil?
      random_sleep
      URI.open(url.delete_suffix('/'), options) # rubocop:disable Security/Open
    end

    def module_name
      {
        'www.mai-net.net' => 'Arcadia',
        'ncode.syosetu.com' => 'Narou',
        'syosetu.org' => 'Hameln',
        'www.akatsuki-novels.com' => 'Akatsuki',
        'novel18.syosetu.com' => 'Nocturne'
      }
    end
  end
end
