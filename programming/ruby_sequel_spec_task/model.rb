require 'sequel'

# Sequel model for Comet Data Model

# Load extensions
Sequel.extension :sql_expr

# DB connection
#DB = Sequel.connect 'ado://vulcan_dev:vulcan_dev@localhost/vulcan', :provider => 'SQLNCLI'
DB = Sequel.connect 'mysql://vikas@localhost/vulcan'

module Vulcan
  module Tracking

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

    class Searchterm < Sequel::Model
      def get_searchterm(referer)
        case referer
        when %r|^http://www\.google\.com/.*[?&](as_)?q=([^&/]+)|
          return unescape($2)

        when %r|^http://www\.webcrawler\.com/.*/results/Web/([^&/]+)|,
          %r|^http://www\.ask\.com/.*[?&]q=([^&/]+)|,
          %r|^http://search\.aol\.com/.*[?&]query=([^&/]+)|,
          %r|^http://search\.hp\.my\.aol\.com/.*[?&]query=([^&/]+)|,
          %r|^http://search\.yahoo\.com/.*[?&]p=([^&/]+)|,
          %r|^http://search\.comcast\.net/.*[?&]q=([^&/]+)|,
          %r|^http://search\.myway\.com/.*[?&]searchfor=([^&/]+)|,
          %r|^http://search\.rr\.com/.*[?&]qs=([^&/]+)|,
          %r|^http://www\.bing\.com/.*[?&]q=([^&/]+)|,
          %r|^http://www\.avantfind\.com/.*[?&]keywords=([^&/]+)|,
          %r|^http://www\.goodsearch\.com/.*[?&]keywords=([^&/]+)|,
          %r|^http://www\.dogpile\.com/.*/results/Web/([^&/]+)|
          return unescape($1)

        when %r|^http://www\.mahalo\.com/([^?&/]+)|
          return $1.gsub('-', ' ')

        when %r|^http://wwz\.websearch\.verizon\.net/.*[?&]next=([^&/]+)|
          str1 = unescape($1)
          str1 =~ %r|[&]?Keywords=([^&?/]+)|
          return unescape($1)

        when %r|^http://googleads\.g\.doubleclick.net/|, %r|^http://www.offers.com/|
          return ''

        else
          return nil
        end
      end

      protected
      def unescape(string)
        string.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n) do
          [$1.delete('%')].pack('H*') if $1[1..2].hex < 129
        end  
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
