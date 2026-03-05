# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NovelScraping do
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
        rescue RuntimeError
          nil
        end
        expect(mock_logger).to have_received(:error).with("HTTP Request Failed: 403 #{url}")
      end

      it 'raises a RuntimeError with the status code' do
        expect { described_class.uri_open(url) }.to raise_error(RuntimeError, 'HTTP Request Failed: 403')
      end
    end
  end
end
