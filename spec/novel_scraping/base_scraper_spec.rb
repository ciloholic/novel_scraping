# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NovelScraping::BaseScraper do
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

  describe '.get_chapter' do
    it 'fetches HTML and extracts content based on XML_CONTENT' do
      url = 'https://example.com/chapter/1'
      allow(NovelScraping).to receive(:uri_open).with(url, {}).and_return(html_body)

      content = test_scraper.get_chapter(url)
      expect(content).to eq 'test content'
    end

    it 'removes newlines from content' do
      url = 'https://example.com/chapter/1'
      html_with_newlines = "<html><body><div class=\"content\">line1\r\nline2\nline3</div></body></html>"
      allow(NovelScraping).to receive(:uri_open).with(url, {}).and_return(html_with_newlines)

      content = test_scraper.get_chapter(url)
      expect(content).to eq 'line1line2line3'
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
      allow(NovelScraping).to receive(:uri_open).with(url, { cookie: 'over18=yes' }).and_return(html_body)

      content = cookie_scraper.get_chapter(url)
      expect(content).to eq 'test content'
    end
  end
end
