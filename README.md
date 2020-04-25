# Novel Scraping

novel scraping is a gem that scrapes fan fiction novel sites.

## Status

![](https://github.com/ciloholic/novel_scraping/workflows/Rspec/badge.svg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'novel_scraping', git: 'https://github.com/ciloholic/novel_scraping.git'
```

## Usage

```
# Scraping all the information for the novel title and each chapter
url = 'https://hogehoge/000000'
title, chapters = NovelScraping.access(url)

# title
=> 'novel title'

# chapters
=>
[
  {
    url: 'https://hogehoge/000000/1',
    sub_title: 'sub title',
    post_at: 2020-01-01 00:00:00 +0900,
    edit_at: 2020-01-01 00:00:00 +0900,
    count: 1,
    content: 'content'
  }
]
```

```
# Use `from` option to scrap chapters after the post date
title, chapters = NovelScraping.access(url, from: '2020-01-01 00:00:00')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
