# global work db and list of pages to work for the "Job"

require "yaml"

# ::Crawl::Jobs::PagesToProcessList   will hold the work list of pages to pull and process
# ::Crawl::Db:: ...                   will hold various information about the pages we find
#                                     so that we can build up a site map.


module Crawl
  module Jobs
    PagesToProcessList = []     ### stores a work list, we loop processing pages until this i sempty
  end

  module Db

    # goal is to store a simple site map, of a starting url, an dlinks to other pages under same domain,
    # keeping separate links to static content of images
    # also keeping separate urls from external sites


    class PageDb
      attr_accessor :root_page

      # all of these hold hash to links, we keep track of
      # non-internal liinks,
      #     internal links (from our site), and
      #   static content
      attr_accessor :non_internal_links, :static_content_links, :internal_links

      def initialize
        @non_internal_links = Hash.new
        @static_content_links = Hash.new
        @internal_links = Hash.new

      end

    end

    SiteMap = PageDb.new


    class Entry
      attr_accessor :label, :url, :count   ## note we might not set the url if the url is used as a hash key
    end

  end
end