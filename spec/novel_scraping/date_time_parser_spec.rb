# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NovelScraping::DateTimeParser do
  describe '.parse' do
    context 'when nil or empty string is given' do
      it 'returns nil for nil input' do
        expect(described_class.parse(nil, :slash_format)).to be_nil
      end

      it 'returns nil for empty string input' do
        expect(described_class.parse('', :slash_format)).to be_nil
      end
    end

    context ':slash_format (for Narou/Nocturne/Arcadia)' do
      it 'parses YYYY/MM/DD HH:MM format' do
        result = described_class.parse('2020/01/01 00:00', :slash_format)
        expect(result).to eq Time.parse('2020/01/01 00:00')
      end

      it 'parses even with surrounding text' do
        result = described_class.parse('更新日: 2020/12/31 23:59 (改)', :slash_format)
        expect(result).to eq Time.parse('2020/12/31 23:59')
      end

      it 'returns nil when no match is found' do
        expect(described_class.parse('invalid date', :slash_format)).to be_nil
      end
    end

    context ':japanese_space (for Hameln)' do
      it 'parses YYYY年MM月DD日 HH:MM format' do
        result = described_class.parse('2020年01月01日 00:00', :japanese_space)
        expect(result).to eq Time.strptime('2020年01月01日 00:00', '%Y年%m月%d日 %H:%M')
      end

      it 'returns nil for invalid format' do
        expect(described_class.parse('2020/01/01 00:00', :japanese_space)).to be_nil
      end
    end

    context ':japanese_full (for Akatsuki)' do
      it 'parses YYYY年MM月DD日HH時MM分 format' do
        result = described_class.parse('2020年01月01日00時00分', :japanese_full)
        expect(result).to eq Time.strptime('2020年01月01日00時00分', '%Y年%m月%d日%H時%M分')
      end

      it 'returns nil for invalid format' do
        expect(described_class.parse('2020年01月01日 00:00', :japanese_full)).to be_nil
      end
    end

    context 'when invalid datetime string is given' do
      it 'returns nil for non-existent date' do
        expect(described_class.parse('2020/13/99 99:99', :slash_format)).to be_nil
      end
    end
  end
end
