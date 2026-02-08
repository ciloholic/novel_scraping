# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NovelScraping do
  describe '.logger' do
    after do
      described_class.logger = nil
    end

    context 'without Rails' do
      it 'returns an ActiveSupport::Logger instance' do
        expect(described_class.logger).to be_a(ActiveSupport::Logger)
      end

      it 'uses a formatter that outputs timestamp and message' do
        output = StringIO.new
        described_class.logger = ActiveSupport::Logger.new(output).tap do |log|
          log.formatter = described_class.logger.formatter
        end
        described_class.logger.info('test message')
        expect(output.string).to match(/\A\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\] test message\n\z/)
      end
    end

    context 'with Rails' do
      let(:rails_logger) { ActiveSupport::Logger.new(StringIO.new) }

      before do
        stub_const('Rails', Struct.new(:logger).new(rails_logger))
      end

      it 'returns Rails.logger' do
        expect(described_class.logger).to eq(rails_logger)
      end
    end

    context 'with custom logger' do
      let(:custom_logger) { ActiveSupport::Logger.new(StringIO.new) }

      it 'returns the custom logger' do
        described_class.logger = custom_logger
        expect(described_class.logger).to eq(custom_logger)
      end
    end
  end

  describe '.verbose' do
    after do
      described_class.verbose = nil
    end

    it 'returns true by default' do
      expect(described_class.verbose).to be true
    end

    it 'returns false when set to false' do
      described_class.verbose = false
      expect(described_class.verbose).to be false
    end

    it 'returns true when set to true' do
      described_class.verbose = true
      expect(described_class.verbose).to be true
    end
  end
end
