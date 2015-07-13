require 'watir-webdriver'
require 'nokogiri'
require 'time'
require "yaml"

require_relative 'work_db'
require_relative 'url_parse'
require_relative 'page_scanner'

## module to store what browser to use to crawl the web; we use a real browser so that we can navigate real
## javascript
module Crawl
  module SkipList
    SKIP_URLS_REGEX = ["google.com", "twitter.com", "facebook.com"].map { |url|  /#{url}$/ }
  end

  module Browser
    KIND_OF_BROWSER = :firefox
    @@browser = Watir::Browser.new   KIND_OF_BROWSER
    at_exit { @@browser.close}


    def browser
      @@browser
    end
  end

  # general err that we will use
  class ScanPageNotFound < StandardError

  end


  ######################################################################

  class ScanPage
    include Browser
    include UrlParse

    @@page_scanner = ::Crawl::PageScanner.new

    def initialize(root_url)
       puts "starting a new crawl at #{Time.new} for #{root_url}"
       ::Crawl::Db::SiteMap.root_page = root_url

       ::Crawl::Jobs::PagesToProcessList << root_url
       process_all_urls
    end

    def process_all_urls
      while  ::Crawl::Jobs::PagesToProcessList.size > 0
        url =  ::Crawl::Jobs::PagesToProcessList.shift
        process_url(url)
      end
    end

    private

    # we want to skip hosts like "google.com", "twitter.com", "facebook.com", in such a case
    # this will return true, otherwise false
    def should_skip(url)
       skip = false

       ::Crawl::SkipList::SKIP_URLS_REGEX.each do |regex_to_skip|
             skip = true   if url.host =~ regex_to_skip
       end

       return skip
    end


    # process a single url
    def process_url(url)
      begin

        # the following scans
        url_kind_normalized = is_valid_url(url, nil)
        url_kind = url_kind_normalized[0]
        url = url_kind_normalized[1]  ## normalized i.e. canonical format

        unless  [:ref_static_content, :not_valid_url].include?(url_kind)
          if  ::Crawl::Db::SiteMap.internal_links[url] || ::Crawl::Db::SiteMap.non_internal_links[url] || should_skip(url)
            # already scanned, we could bump the count if needed
            # if skip just skip!
          else
            # scan it and all its nested pages
            navigate_to_url_and_validate_that_url_was_found(  url )
            page_content = browser.html
            @@page_scanner.scan_content(page_content, url)
          end
        end

      rescue StandardError  => err
        puts "Err: on url #{url} received: #{err}"
      end

    end


    def navigate_to_url_and_validate_that_url_was_found(url)
      browser.goto  url
      validate_that_url_was_found
    end


    def validate_that_url_was_found
      if @@browser.text =~  /^Server not found\n/
        raise ScanPageNotFound
      end
    end

  end
end
