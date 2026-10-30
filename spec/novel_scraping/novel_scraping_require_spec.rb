# frozen_string_literal: true

require 'open3'

RSpec.describe NovelScraping do
  describe 'require' do
    # Run in a separate process, since spec_helper loads all of ActiveSupport
    it 'loads the ActiveSupport extensions used by the scrapers' do
      script = "require 'novel_scraping'; print [Time.now.present?, nil.present?].inspect"
      output, status = Open3.capture2e(RbConfig.ruby, '-Ilib', '-e', script)
      expect([output, status.success?]).to eq(['[true, false]', true])
    end
  end
end
