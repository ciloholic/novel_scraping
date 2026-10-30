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
    let(:target) { instance_double(Ferrum::Target, page:) }
    let(:context) { instance_double(Ferrum::Context, targets: { 'TARGET_ID' => target }) }
    let(:browser) { instance_double(Ferrum::Browser, default_context: context, command: nil, quit: nil) }

    before do
      allow(described_class).to receive(:random_sleep)
      allow(described_class).to receive(:logger).and_return(mock_logger)
      described_class.cdp_url = cdp_url
      allow(Ferrum::Browser).to receive(:new).and_return(browser)
      allow(browser).to receive(:command)
        .with('Target.createTarget', url: 'about:blank', background: true)
        .and_return('targetId' => 'TARGET_ID')
      allow(Faraday).to receive(:get)
    end

    after { described_class.cdp_url = nil }

    it 'connects to the running Chrome with cdp_url' do
      described_class.uri_open(url)
      expect(Ferrum::Browser).to have_received(:new).with(hash_including(url: cdp_url))
    end

    it 'waits longer than the Ferrum default timeout of 5 seconds' do
      described_class.uri_open(url)
      expect(Ferrum::Browser).to have_received(:new).with(hash_including(timeout: 30))
    end

    context 'when cdp_url uses a hostname such as host.docker.internal' do
      let(:cdp_url) { 'http://host.docker.internal:9222' }

      before { allow(Resolv).to receive(:getaddress).with('host.docker.internal').and_return('192.168.65.254') }

      it 'connects with the resolved IP address because Chrome rejects Host headers other than IP addresses and localhost' do
        described_class.uri_open(url)
        expect(Ferrum::Browser).to have_received(:new).with(hash_including(url: 'http://192.168.65.254:9222'))
      end
    end

    context 'when cdp_url uses localhost' do
      let(:cdp_url) { 'http://localhost:9222' }

      before { allow(Resolv).to receive(:getaddress) }

      it 'connects with cdp_url as it is' do
        described_class.uri_open(url)
        expect(Ferrum::Browser).to have_received(:new).with(hash_including(url: cdp_url))
        expect(Resolv).not_to have_received(:getaddress)
      end
    end

    it 'opens a new tab in the background and returns the page body' do
      expect(described_class.uri_open(url)).to eq('<html>cdp</html>')
      expect(browser).to have_received(:command).with('Target.createTarget', url: 'about:blank', background: true)
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

    context 'when connecting to the new tab fails' do
      before { allow(target).to receive(:page).and_raise(Ferrum::TimeoutError) }

      it 'raises a RuntimeError like the Faraday version' do
        expect { described_class.uri_open(url) }.to raise_error(RuntimeError, /\AFerrum Error: /)
      end

      it 'closes the tab by its target id and disconnects from Chrome' do
        begin
          described_class.uri_open(url)
        rescue RuntimeError
          nil
        end
        expect(browser).to have_received(:command).with('Target.closeTarget', targetId: 'TARGET_ID')
        expect(browser).to have_received(:quit)
      end
    end

    context 'when the new tab is not registered in time' do
      let(:context) { instance_double(Ferrum::Context, targets: {}) }

      before { stub_const('NovelScraping::CDP_TIMEOUT', 0) }

      it 'raises a RuntimeError like the Faraday version' do
        expect { described_class.uri_open(url) }.to raise_error(RuntimeError, /\AFerrum Error: /)
      end

      it 'closes the tab by its target id and disconnects from Chrome' do
        begin
          described_class.uri_open(url)
        rescue RuntimeError
          nil
        end
        expect(browser).to have_received(:command).with('Target.closeTarget', targetId: 'TARGET_ID')
        expect(browser).to have_received(:quit)
      end
    end
  end
end
