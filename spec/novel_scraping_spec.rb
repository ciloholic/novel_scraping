# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NovelScraping do
  before do
    @arcadia = {
      html_top: File.read('./spec/fixtures/arcadia/arcadia.html'),
      html_chapter1: File.read('./spec/fixtures/arcadia/arcadia_1.html'),
      main_title: 'arcadia title',
      chapters: [
        { url: 'http://www.mai-net.net/bbs/sst/sst.php?act=dump&cate=akamatu&all=00000&n=0#kiji', sub_title: 'arcadia title', post_at: Time.parse('2020-01-01 00:00:00'), edit_at: Time.parse('2020-01-01 00:00:00'), count: 0 },
        { url: 'http://www.mai-net.net/bbs/sst/sst.php?act=dump&cate=akamatu&all=00000&n=1#kiji', sub_title: 'chapter-1', post_at: Time.parse('2020-01-02 00:00:00'), edit_at: Time.parse('2020-01-02 00:00:00'), count: 1 },
        { url: 'http://www.mai-net.net/bbs/sst/sst.php?act=dump&cate=akamatu&all=00000&n=2#kiji', sub_title: 'chapter-2', post_at: Time.parse('2020-01-03 00:00:00'), edit_at: Time.parse('2020-01-03 00:00:00'), count: 2 }
      ]
    }
    @narou = {
      html_top: File.read('./spec/fixtures/narou/narou.html'),
      html_chapter1: File.read('./spec/fixtures/narou/narou_1.html'),
      main_title: 'narou title',
      chapters: [
        { url: 'https://ncode.syosetu.com/n000000/1/', sub_title: 'chapter-1', post_at: Time.parse('2020-01-01 00:00:00'), edit_at: Time.parse('2020-01-01 01:00:00'), count: 1 },
        { url: 'https://ncode.syosetu.com/n000000/2/', sub_title: 'chapter-2', post_at: Time.parse('2020-01-02 00:00:00'), edit_at: Time.parse('2020-01-02 01:00:00'), count: 2 },
        { url: 'https://ncode.syosetu.com/n000000/3/', sub_title: 'chapter-3', post_at: Time.parse('2020-01-03 00:00:00'), edit_at: Time.parse('2020-01-03 00:00:00'), count: 3 }
      ]
    }
    @hameln = {
      html_top: File.read('./spec/fixtures/hameln/hameln.html'),
      html_chapter1: File.read('./spec/fixtures/hameln/hameln_1.html'),
      main_title: 'hameln title',
      chapters: [
        { url: 'https://syosetu.org/novel/000000/1.html', sub_title: 'chapter-1', post_at: Time.parse('2020-01-01 00:00:00'), edit_at: Time.parse('2020-01-01 01:00:00'), count: 1 },
        { url: 'https://syosetu.org/novel/000000/2.html', sub_title: 'chapter-2', post_at: Time.parse('2020-01-02 00:00:00'), edit_at: Time.parse('2020-01-02 01:00:00'), count: 2 },
        { url: 'https://syosetu.org/novel/000000/3.html', sub_title: 'chapter-3', post_at: Time.parse('2020-01-03 00:00:00'), edit_at: Time.parse('2020-01-03 00:00:00'), count: 3 }
      ]
    }
    @akatsuki = {
      html_top: File.read('./spec/fixtures/akatsuki/akatsuki.html'),
      html_chapter1: File.read('./spec/fixtures/akatsuki/akatsuki_1.html'),
      main_title: 'akatsuki title',
      chapters: [
        { url: 'https://www.akatsuki-novels.com/stories/view/1/novel_id~000000', sub_title: 'chapter-1', post_at: Time.parse('2020-01-01 00:00:00'), edit_at: Time.parse('2020-01-01 00:00:00'), count: 1 },
        { url: 'https://www.akatsuki-novels.com/stories/view/2/novel_id~000000', sub_title: 'chapter-2', post_at: Time.parse('2020-01-02 00:00:00'), edit_at: Time.parse('2020-01-02 00:00:00'), count: 2 },
        { url: 'https://www.akatsuki-novels.com/stories/view/3/novel_id~000000', sub_title: 'chapter-3', post_at: Time.parse('2020-01-03 00:00:00'), edit_at: Time.parse('2020-01-03 00:00:00'), count: 3 }
      ]
    }
    @nocturne = {
      html_top: File.read('./spec/fixtures/nocturne/nocturne.html'),
      html_chapter1: File.read('./spec/fixtures/nocturne/nocturne_1.html'),
      main_title: 'nocturne title',
      chapters: [
        { url: 'https://novel18.syosetu.com/n000000/1/', sub_title: 'chapter-1', post_at: Time.parse('2020-01-01 00:00:00'), edit_at: Time.parse('2020-01-01 01:00:00'), count: 1 },
        { url: 'https://novel18.syosetu.com/n000000/2/', sub_title: 'chapter-2', post_at: Time.parse('2020-01-02 00:00:00'), edit_at: Time.parse('2020-01-02 01:00:00'), count: 2 },
        { url: 'https://novel18.syosetu.com/n000000/3/', sub_title: 'chapter-3', post_at: Time.parse('2020-01-03 00:00:00'), edit_at: Time.parse('2020-01-03 00:00:00'), count: 3 }
      ]
    }
  end

  context 'arcadia group' do
    it 'NovelScraping::Arcadia.get_site test' do
      url = 'http://www.mai-net.net/bbs/sst/sst.php?act=dump&cate=akamatu&all=00000&n=0#kiji'
      allow(NovelScraping).to receive(:uri_open).and_return(@arcadia[:html_top]).with(url)
      main_title, chapters = NovelScraping::Arcadia.get_site(url)
      expect(main_title).to eq @arcadia[:main_title]
      expect(chapters).to eq @arcadia[:chapters]
    end

    it 'NovelScraping::Arcadia.get_chapter test' do
      url = 'http://www.mai-net.net/bbs/sst/sst.php?act=dump&cate=akamatu&all=00000&n=1#kiji'
      allow(NovelScraping).to receive(:uri_open).and_return(@arcadia[:html_chapter1]).with(url)
      content = NovelScraping::Arcadia.get_chapter(url)
      expect(content).to eq 'arcadia chapter-1 content'
    end

    it 'NovelScraping::Arcadia.datetime test' do
      expect(NovelScraping::Arcadia.send(:datetime)).to be_nil
      expect(NovelScraping::Arcadia.send(:datetime, '')).to be_nil
      expect(NovelScraping::Arcadia.send(:datetime, '2020/01/01 00:00')).to eq Time.parse('2020/01/01 00:00')
    end
  end

  context 'narou group' do
    it 'NovelScraping::Narou.get_site test' do
      url = 'https://ncode.syosetu.com/n000000/'
      allow(NovelScraping).to receive(:uri_open).and_return(@narou[:html_top]).with(url)
      main_title, chapters = NovelScraping::Narou.get_site(url)
      expect(main_title).to eq @narou[:main_title]
      expect(chapters).to eq @narou[:chapters]
    end

    it 'NovelScraping::Narou.get_chapter test' do
      url = 'https://ncode.syosetu.com/n000000/1/'
      allow(NovelScraping).to receive(:uri_open).and_return(@narou[:html_chapter1]).with(url)
      content = NovelScraping::Narou.get_chapter(url)
      expect(content).to eq 'narou chapter-1 content'
    end

    it 'NovelScraping::Narou.datetime test' do
      expect(NovelScraping::Narou.send(:datetime)).to be_nil
      expect(NovelScraping::Narou.send(:datetime, '')).to be_nil
      expect(NovelScraping::Narou.send(:datetime, '2020/01/01 00:00')).to eq Time.parse('2020/01/01 00:00')
    end
  end

  context 'hameln group' do
    it 'NovelScraping::Hameln.get_site test' do
      url = 'https://syosetu.org/novel/000000/'
      allow(NovelScraping).to receive(:uri_open).and_return(@hameln[:html_top]).with(url, { 'Cookie' => 'over18=off' })
      main_title, chapters = NovelScraping::Hameln.get_site(url)
      expect(main_title).to eq @hameln[:main_title]
      expect(chapters).to eq @hameln[:chapters]
    end

    it 'NovelScraping::Hameln.get_chapter test' do
      url = 'https://syosetu.org/novel/000000/1.html'
      allow(NovelScraping).to receive(:uri_open).and_return(@hameln[:html_chapter1]).with(url, { 'Cookie' => 'over18=off' })
      content = NovelScraping::Hameln.get_chapter(url)
      expect(content).to eq 'hameln chapter-1 content'
    end

    it 'NovelScraping::Hameln.datetime test' do
      expect(NovelScraping::Hameln.send(:datetime)).to be_nil
      expect(NovelScraping::Hameln.send(:datetime, '')).to be_nil
      expect(NovelScraping::Hameln.send(:datetime, '2020年01月01日 00:00')).to eq Time.strptime('2020年01月01日 00:00', '%Y年%m月%d日 %H:%M')
    end
  end

  context 'akatsuki group' do
    it 'NovelScraping::Akatsuki.get_site test' do
      url = 'https://www.akatsuki-novels.com/stories/index/novel_id~000000'
      allow(NovelScraping).to receive(:uri_open).and_return(@akatsuki[:html_top]).with(url)
      main_title, chapters = NovelScraping::Akatsuki.get_site(url)
      expect(main_title).to eq @akatsuki[:main_title]
      expect(chapters).to eq @akatsuki[:chapters]
    end

    it 'NovelScraping::Akatsuki.get_chapter test' do
      url = 'https://www.akatsuki-novels.com/stories/view/1/novel_id~000000'
      allow(NovelScraping).to receive(:uri_open).and_return(@akatsuki[:html_chapter1]).with(url)
      content = NovelScraping::Akatsuki.get_chapter(url)
      expect(content).to eq 'akatsuki chapter-1 content'
    end

    it 'NovelScraping::Akatsuki.datetime test' do
      expect(NovelScraping::Akatsuki.send(:datetime)).to be_nil
      expect(NovelScraping::Akatsuki.send(:datetime, '')).to be_nil
      expect(NovelScraping::Akatsuki.send(:datetime, '2020年01月01日00時00分')).to eq Time.strptime('2020年01月01日00時00分', '%Y年%m月%d日%H時%M分')
    end
  end

  context 'nocturne group' do
    it 'NovelScraping::Nocturne.get_site test' do
      url = 'https://novel18.syosetu.com/n000000/'
      allow(NovelScraping).to receive(:uri_open).and_return(@nocturne[:html_top]).with(url, { 'Cookie' => 'over18=yes' })
      main_title, chapters = NovelScraping::Nocturne.get_site(url)
      expect(main_title).to eq @nocturne[:main_title]
      expect(chapters).to eq @nocturne[:chapters]
    end

    it 'NovelScraping::Nocturne.get_chapter test' do
      url = 'https://novel18.syosetu.com/n000000/1/'
      allow(NovelScraping).to receive(:uri_open).and_return(@nocturne[:html_chapter1]).with(url, { 'Cookie' => 'over18=yes' })
      content = NovelScraping::Nocturne.get_chapter(url)
      expect(content).to eq 'nocturne chapter-1 content'
    end

    it 'NovelScraping::Nocturne.datetime test' do
      expect(NovelScraping::Nocturne.send(:datetime)).to be_nil
      expect(NovelScraping::Nocturne.send(:datetime, '')).to be_nil
      expect(NovelScraping::Nocturne.send(:datetime, '2020/01/01 00:00')).to eq Time.parse('2020/01/01 00:00')
    end
  end
end
