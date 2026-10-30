# frozen_string_literal: true

require 'spec_helper'
require 'ferrum'

RSpec.describe NovelScraping do
  describe 'HttpError' do
    it 'is a subclass of StandardError' do
      expect(NovelScraping::HttpError.ancestors).to include(StandardError)
    end

    it 'stores the HTTP status code' do
      error = NovelScraping::HttpError.new(403)
      expect(error.status).to eq(403)
    end

    it 'has a descriptive message' do
      error = NovelScraping::HttpError.new(403)
      expect(error.message).to eq('HTTP Request Failed: 403')
    end
  end

  describe '.uri_open' do
    let(:url) { 'https://example.com/page' }
    let(:mock_logger) { instance_spy(ActiveSupport::Logger) }

    before do
      allow(described_class).to receive(:random_sleep)
      allow(described_class).to receive(:logger).and_return(mock_logger)
    end

    context 'when the HTTP request fails' do
      let(:mock_response) { instance_double(Faraday::Response, success?: false, status: 403) }

      before do
        allow(Faraday).to receive(:get).and_return(mock_response)
      end

      it 'logs the error with status code and URL' do
        begin
          described_class.uri_open(url)
        rescue NovelScraping::HttpError
          nil
        end
        expect(mock_logger).to have_received(:error).with("HTTP Request Failed: 403 #{url}")
      end

      it 'raises an HttpError with the status code' do
        expect { described_class.uri_open(url) }.to raise_error(NovelScraping::HttpError, 'HTTP Request Failed: 403')
      end

      it 'raises an HttpError with status attribute' do
        expect { described_class.uri_open(url) }.to raise_error(NovelScraping::HttpError) do |e|
          expect(e.status).to eq(403)
        end
      end
    end

    context 'when cdp_url is not set' do
      let(:mock_response) { instance_double(Faraday::Response, success?: true, body: '<html>faraday</html>') }

      before do
        allow(Faraday).to receive(:get).and_return(mock_response)
        allow(Ferrum::Browser).to receive(:new)
      end

      it 'fetches the page with Faraday' do
        expect(described_class.uri_open(url)).to eq('<html>faraday</html>')
        expect(Faraday).to have_received(:get).with(url)
      end

      it 'does not connect to Chrome' do
        described_class.uri_open(url)
        expect(Ferrum::Browser).not_to have_received(:new)
      end
    end
  end

  describe '.uri_open when cdp_url is set' do
    let(:mock_logger) { instance_spy(ActiveSupport::Logger) }
    let(:cdp_url) { 'http://127.0.0.1:9222' }
    let(:url) { 'https://novel18.syosetu.com/n000000/' }
    let(:status) { 200 }
    let(:network) { instance_double(Ferrum::Network, status:) }
    let(:cookies) { instance_double(Ferrum::Cookies, set: true) }
    let(:page) { instance_double(Ferrum::Page, go_to: nil, body: '<html>cdp</html>', close: nil, network:, cookies:) }
    let(:browser) { instance_double(Ferrum::Browser, create_page: page, quit: nil) }

    before do
      allow(described_class).to receive(:random_sleep)
      allow(described_class).to receive(:logger).and_return(mock_logger)
      described_class.cdp_url = cdp_url
      allow(Ferrum::Browser).to receive(:new).and_return(browser)
      allow(Faraday).to receive(:get)
    end

    after { described_class.cdp_url = nil }

    it 'connects to the running Chrome with cdp_url' do
      described_class.uri_open(url)
      expect(Ferrum::Browser).to have_received(:new).with(hash_including(url: cdp_url))
    end

    it 'opens a new tab and returns the page body' do
      expect(described_class.uri_open(url)).to eq('<html>cdp</html>')
      expect(browser).to have_received(:create_page)
      expect(page).to have_received(:go_to).with(url)
    end

    it 'does not use Faraday' do
      described_class.uri_open(url)
      expect(Faraday).not_to have_received(:get)
    end

    it 'closes the tab and disconnects from Chrome after fetching' do
      described_class.uri_open(url)
      expect(page).to have_received(:close)
      expect(browser).to have_received(:quit)
    end

    it 'sets the cookie for the target domain before fetching' do
      described_class.uri_open(url, { cookie: 'over18=yes' })
      expect(cookies).to have_received(:set).with(name: 'over18', value: 'yes', domain: 'novel18.syosetu.com').ordered
      expect(page).to have_received(:go_to).with(url).ordered
    end

    it 'does not set any cookie when the cookie option is not given' do
      described_class.uri_open(url)
      expect(cookies).not_to have_received(:set)
    end

    it 'ignores the user_agent and referer options to keep the browser defaults' do
      # headers is not stubbed on the instance_double, so any attempt to change headers fails
      expect(described_class.uri_open(url, { user_agent: 'TestAgent/1.0', referer: 'https://example.com/' })).to eq('<html>cdp</html>')
    end

    context 'when the HTTP status is not successful' do
      let(:status) { 403 }

      it 'raises an HttpError with the status code' do
        expect { described_class.uri_open(url) }.to raise_error(NovelScraping::HttpError) do |e|
          expect(e.status).to eq(403)
        end
      end

      it 'logs the error with status code and URL' do
        begin
          described_class.uri_open(url)
        rescue NovelScraping::HttpError
          nil
        end
        expect(mock_logger).to have_received(:error).with("HTTP Request Failed: 403 #{url}")
      end

      it 'still closes the tab and disconnects from Chrome' do
        begin
          described_class.uri_open(url)
        rescue NovelScraping::HttpError
          nil
        end
        expect(page).to have_received(:close)
        expect(browser).to have_received(:quit)
      end
    end

    context 'when Ferrum raises an error' do
      before { allow(page).to receive(:go_to).and_raise(Ferrum::TimeoutError) }

      it 'raises a RuntimeError like the Faraday version' do
        expect { described_class.uri_open(url) }.to raise_error(RuntimeError, /\AFerrum Error: /)
      end

      it 'still closes the tab and disconnects from Chrome' do
        begin
          described_class.uri_open(url)
        rescue RuntimeError
          nil
        end
        expect(page).to have_received(:close)
        expect(browser).to have_received(:quit)
      end
    end
  end
end
