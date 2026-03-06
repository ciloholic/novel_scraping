# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NovelScraping::BaseScraper do
  let(:test_ua) { 'TestAgent/1.0' }

  let(:test_scraper) do
    Class.new(described_class) do
      const_set(:XML_CONTENT, '//div[@class="content"]')
    end
  end

  let(:cookie_scraper) do
    Class.new(described_class) do
      const_set(:XML_CONTENT, '//div[@class="content"]')

      class << self
        protected

        def request_options
          { cookie: 'over18=yes' }
        end
      end
    end
  end

  let(:html_body) do
    '<html><body><div class="content">test content</div></body></html>'
  end

  before do
    allow(test_scraper).to receive(:user_agent).and_return(test_ua)
    allow(cookie_scraper).to receive(:user_agent).and_return(test_ua)
  end

  describe '.user_agent' do
    it 'returns a string' do
      scraper = Class.new(described_class) { const_set(:XML_CONTENT, '//div') }
      expect(scraper.send(:user_agent)).to be_a(String)
    end

    it 'returns the same user agent on repeated calls (memoized)' do
      scraper = Class.new(described_class) { const_set(:XML_CONTENT, '//div') }
      ua1 = scraper.send(:user_agent)
      ua2 = scraper.send(:user_agent)
      expect(ua1).to eq(ua2)
    end

    it 'returns different user agents for different scraper classes' do
      scraper1 = Class.new(described_class) { const_set(:XML_CONTENT, '//div') }
      scraper2 = Class.new(described_class) { const_set(:XML_CONTENT, '//div') }
      allow(Faker::Internet).to receive(:user_agent).and_return('Agent1/1.0', 'Agent2/2.0')
      expect(scraper1.send(:user_agent)).not_to eq(scraper2.send(:user_agent))
    end
  end

  describe '.get_chapter' do
    it 'fetches HTML and extracts content based on XML_CONTENT' do
      url = 'https://example.com/chapter/1'
      allow(NovelScraping).to receive(:uri_open).with(url, { user_agent: test_ua }).and_return(html_body)

      content = test_scraper.get_chapter(url)
      expect(content).to eq 'test content'
    end

    it 'removes newlines from content' do
      url = 'https://example.com/chapter/1'
      html_with_newlines = "<html><body><div class=\"content\">line1\r\nline2\nline3</div></body></html>"
      allow(NovelScraping).to receive(:uri_open).with(url, { user_agent: test_ua }).and_return(html_with_newlines)

      content = test_scraper.get_chapter(url)
      expect(content).to eq 'line1line2line3'
    end

    it 'passes referer to uri_open when specified' do
      url = 'https://example.com/chapter/1'
      referer = 'https://example.com/'
      allow(NovelScraping).to receive(:uri_open).with(url, { user_agent: test_ua, referer: }).and_return(html_body)

      content = test_scraper.get_chapter(url, referer:)
      expect(content).to eq 'test content'
    end

    it 'passes cookie and referer to uri_open when both specified' do
      url = 'https://example.com/chapter/1'
      referer = 'https://example.com/'
      allow(NovelScraping).to receive(:uri_open).with(url, { cookie: 'over18=yes', user_agent: test_ua, referer: }).and_return(html_body)

      content = cookie_scraper.get_chapter(url, referer:)
      expect(content).to eq 'test content'
    end
  end

  describe '.request_options' do
    it 'returns an empty hash by default' do
      expect(test_scraper.send(:request_options)).to eq({})
    end

    it 'can be overridden in subclasses' do
      expect(cookie_scraper.send(:request_options)).to eq({ cookie: 'over18=yes' })
    end

    it 'passes request_options to get_chapter' do
      url = 'https://example.com/chapter/1'
      allow(NovelScraping).to receive(:uri_open).with(url, { cookie: 'over18=yes', user_agent: test_ua }).and_return(html_body)

      content = cookie_scraper.get_chapter(url)
      expect(content).to eq 'test content'
    end
  end
end
