#!/bin/env ruby

# crawl a root page and build a site map.
#
# USAGE:
#      ruby crawler.rb http://www.google.com


require_relative './lib/crawl'


def goto_root_page_start_scan(url)

  scanPageEngine = Crawl::ScanPage.new(url)

  scanPageEngine.process_all_urls()
end

root_url = ARGV[0] || 'http://www.google.com'
goto_root_page_start_scan(root_url)

