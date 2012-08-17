
require 'rubygems'
require 'sequel'
require 'cgi'

# Sequel model for Comet Data Model

# Load extensions
Sequel.extension :sql_expr

# DB connection
DB = Sequel.connect 'mysql://vikas:@localhost/vulcan', :provider => 'SQLNCLI' unless defined?(DB)

module Vulcan
  module Tracking
    class Searchterm
      QUERY_MATCHER = Proc.new do |query, *q_names|
        patterns = q_names.collect{|q_name| /^#{q_name}=(.*)$/}
        $1 if query.split('&').any?{|q| patterns.any?{|p| q =~ p}}
      end
      
      PATH_MATCHER = Proc.new {|path, pattern| $1 if path =~ pattern}
      
      def get_searchterm(referer)
        uri = URI.parse(referer)
        query = uri.query
        path = uri.path
        searchterm = case uri.host
          when 'www.google.com' : QUERY_MATCHER.call(query, 'q', 'as_q')
          when 'www.ask.com', 'www.bing.com', "search.comcast.net" : QUERY_MATCHER.call(query, 'q')
          when 'search.hp.my.aol.com', "search.aol.com" : QUERY_MATCHER.call(query, 'query')
          when 'search.yahoo.com' : QUERY_MATCHER.call(query, 'p')
          when 'search.myway.com' : QUERY_MATCHER.call(query, 'searchfor')
          when 'search.rr.com' : QUERY_MATCHER.call(query, 'qs')
          when 'www.avantfind.com', 'www.goodsearch.com' : QUERY_MATCHER.call(query, 'keywords')
          when 'www.webcrawler.com', 'www.dogpile.com': PATH_MATCHER.call(path, /ws\/results\/Web\/(.*?)\//)
          when 'www.mahalo.com': PATH_MATCHER.call(path, /^\/(.*)$/).gsub(/-/, ' ')
          when 'wwz.websearch.verizon.net' : QUERY_MATCHER.call(CGI.unescape(QUERY_MATCHER.call(query, 'next')), 'Keywords')
          end
        return '' if searchterm.nil?
        
        filter_unrecognized_chars(CGI.unescape(searchterm))
      end
      
      private
      def filter_unrecognized_chars(str)
        str.bytes.to_a.delete_if{|c| c == 153 || c == 174}.collect{|c| c.chr}.to_s
      end
    end
    
    class User < Sequel::Model
      # Associations
      unrestrict_primary_key
      one_to_many :visits
      one_to_many :buyclicks
      one_to_many :orders
    end


    class Visit < Sequel::Model
      # Associations
      many_to_one :user
      many_to_one :path
      many_to_one :linksource
      many_to_one :geo_location
      one_to_many :views
      one_to_many :searches
    end


    class Linksource < Sequel::Model
      # Associations
      one_to_many :visits
    end


    class Searches < Sequel::Model
      # Associations
      unrestrict_primary_key
      many_to_one :visit
    end


    class GeoLocations < Sequel::Model
      # Associations
      one_to_many :visits
      one_to_many :views
    end


    class View < Sequel::Model
      # Associations
      unrestrict_primary_key
      many_to_one :visit
      many_to_one :path
      many_to_one :geo_location
      one_to_many :buyclicks
    end


    class Path < Sequel::Model
      # Associations
      one_to_many :visits
      many_to_one :path_category
    end


    class PathCategory < Sequel::Model
      # Associations
      one_to_many :paths
    end


    class Buyclick < Sequel::Model
      # Associations
      unrestrict_primary_key
      many_to_one :view
      many_to_one :offer
      one_to_many :orders
    end


    class Offer < Sequel::Model
      # Associations
      unrestrict_primary_key
      one_to_many :buyclicks
    end


    class Order < Sequel::Model
      # Associations
      many_to_one :buyclick
      one_to_many :transactions
    end


    class Transaction < Sequel::Model
      # Associations
      many_to_one :order
    end


    class RawSessions < Sequel::Model
      unrestrict_primary_key

      # true if useragent corresponds to a BOT or is junk
      def bot_agent?
        BotAgents.bot_agent?(useragent) || JunkAgents.junk_agent?(useragent)
      end

    end


    class RawPageviews < Sequel::Model
      unrestrict_primary_key
      # Associations
      one_to_many :raw_buyclicks

      @@st = Searchterm.new

      # True if IP corresponds to a BOT
      def bot_ip?
        BotIps.bot_ip?(ip)
      end

      # Return searchterm from referer
      def searchterm
        @@st.get_searchterm(referer)
      end

    end


    class RawBuyclicks < Sequel::Model
      unrestrict_primary_key
      # Associations
      many_to_one :raw_pageview, :key => :view_id

      def self.max_id
        max(:id) || 0
      end

    end


    class RawSearches < Sequel::Model
      unrestrict_primary_key
    end

    class BotAgents < Sequel::Model

      # true is specified agent is a BOT
      def self.bot_agent?(agent)
        filter(({:exact => 1} & {:agent_match => agent}) |
               ({:exact => 0} & agent.sql_expr.like(['%', :agent_match,'%'].sql_string_join))).count > 0
      end
    end


    class JunkAgents < Sequel::Model

      # true is specified agent is Junk
      #TODO: remove the duplication with method bot_agent? in BotAgents class.
      def self.junk_agent?(agent)
        filter(({:exact => 1} & {:agent_match => agent}) |
               ({:exact => 0} & agent.sql_expr.like(['%', :agent_match,'%'].sql_string_join))).count > 0
      end
    end


    class BotIps < Sequel::Model

      # true if specified IP is a BOT
      def self.bot_ip?(ip)
        filter((:ip_low <= ip) & (:ip_high >= ip)).count > 0
      end
    end
    
   
  end
end
