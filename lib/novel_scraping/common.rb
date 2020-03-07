# frozen_string_literal: true

module NovelScraping
  class << self
    def user_agent
      [
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:72.0) Gecko/20100101 Firefox/72.0',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.5 Safari/605.1.15',
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36'
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
  end
end
