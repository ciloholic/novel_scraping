# frozen_string_literal: true

module NovelScraping
  class << self
    def user_agent
      [
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:71.0) Gecko/20100101 Firefox/71.0',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1 Safari/605.1.15',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.149 Safari/537.36',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:74.0) Gecko/20100101 Firefox/74.0'
      ].sample
    end

    def random_sleep(min: 1, max: 4)
      sleep([*min..max].sample)
    end

    def kernel_open(url, option = nil)
      options = { 'User-Agent' => user_agent }
      options.merge!(option) unless option.nil?
      random_sleep
      Kernel.open(url, options)
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
