# code to scan a page for html links
# and add them to the global work database

require 'nokogiri'

require_relative 'work_db'
require_relative 'url_parse'

module Crawl
  module SkipList
    SKIP_URLS_REGEX = ["google.com", "twitter.com", "facebook.com"].map { |url|  /#{url}$/ }
  end

  class PageScanner
    DEBUG = true
    include ::Crawl::UrlParse

    def scan_content(content, from_url)

      doc = Nokogiri::HTML(content)
      puts 'parsed'
      process_nokogiri_doc(doc, from_url)
    end


    # given a Nokogiri document representing a page, look for links and also for the title and also static content
    def process_nokogiri_doc(doc, from_url)
      doc = doc

      doc.css('a').each do |a_tag|
        url = a_tag.attr('href')
        if url
          url_kind_normalized = is_valid_url(url, from_url)
          url_kind = url_kind_normalized[0]
          url = url_kind_normalized[1]
          case url_kind
            when      :ref_same_page
            then
                  puts  url_kind_normalized  if DEBUG
                  ::Crawl::Db::PagesToProcessList << url ## schedule job to process it

            when      :ref_external_page
            then
               puts  url_kind_normalized    if DEBUG

               ## the following effectively does a append to our hash of this url entry

              entry = Crawl::Db::Entry.new()
              entry.url = url
              ::Crawl::Db::SiteMap.non_internal_links[url] = entry

            when      :ref_static_content
            then
                  puts  url_kind_normalized    if DEBUG

                  ## the following effectively does a append to our hash of this url entry

                   entry = Crawl::Db::Entry.new()
                   entry.url = url
                   ::Crawl::Db::SiteMap.static_content_links[url] = entry

            when      :not_valid_url       then puts  url_kind_normalized
          end
        end
      end

      title_entity = doc.css('title')

      if title_entity
           puts ["found title",  doc.css('title').text]
      end

      doc.css('img').each do |a_tag|
        url = a_tag.attr('src')
        if url
          url_kind_normalized = is_valid_url(url, from_url)
          url_kind = url_kind_normalized[0]
          url = url_kind_normalized[1]
          case url_kind
            when      :ref_static_content
            then
            ## the following effectively does a append to our hash of this url entry

            entry = Crawl::Db::Entry.new()
            entry.url = url
            ::Crawl::Db::SiteMap.static_content_links[url] = entry

          end
        end
      end

    end
  end
end