

require File.join(File.dirname(__FILE__), %w[spec_helper])

# Test cases for Tracking data processing

# Model tests
module Vulcan
  module Tracking

    describe "BOT Filtering" do

      before(:all) do
        DB = Sequel.connect 'mysql://vikas:@localhost/vulcan', :provider => 'SQLNCLI'
        
        DB[:bot_agents].delete
        DB[:bot_agents].insert(:exact => 0, :agent_match => 'Googlebot/1234')
        DB[:bot_agents].insert(:exact => 1, :agent_match => 'MSNPTC')
        
        DB[:junk_agents].delete
        DB[:junk_agents].insert(:exact => 0, :agent_match => 'crawler')
        DB[:junk_agents].insert(:exact => 1, :agent_match => 'orca_indexer')
        
        DB[:bot_ips].delete
        DB[:bot_ips].insert(:ip_low => 1094151095, :ip_high => (1094151095 + 100), :name => 'bot_ip_segment_one')
        DB[:bot_ips].insert(:ip_low => 3495458900, :ip_high => (3495458900 + 100), :name => 'bot_ip_segment_two')
        
      end

      # BotAgents
      it "should filter inexact user-agent match" do
        BotAgents.should be_a_bot_agent('Googlebot/1234')
      end

      it "should filter exact user-agent match" do
        BotAgents.should be_a_bot_agent('MSNPTC')
      end

      it "should not filter non-bot user-agent match" do
        BotAgents.should_not be_a_bot_agent('Mozilla')
      end

      # JunkAgents
      it "should filter inexact user-agent match" do
        JunkAgents.should be_a_junk_agent('crawler')
      end

      it "should filter exact user-agent match" do
        JunkAgents.should be_a_junk_agent('orca_indexer')
      end

      it "should not filter non-bot user-agent match" do
        JunkAgents.should_not be_a_junk_agent('Mozilla')
      end

      # BotIps
      it "should filter bot ip's" do
        BotIps.should be_a_bot_ip(3495458900)
        BotIps.should be_a_bot_ip(1094151095)
      end

      it "should not filter non-bot ip'" do
        BotIps.should_not be_a_bot_ip(3495458899)
      end

      # RawSessions
      it "should filter bot agents" do
        raw_session = RawSessions.new(:id => 1, :session_token => '1', :useragent => 'Googlebot/1234')
        raw_session.should be_a_bot_agent

        raw_session.useragent = 'crawler'
        raw_session.should be_a_bot_agent

        raw_session.useragent = 'Mozilla'
        raw_session.should_not be_a_bot_agent
      end

      # RawPageviews
      it "should filter bot ip's" do
        raw_pageview = RawPageviews.new(:id => 1, :session_token => '1', :path => '/', :ip => 3495458900)
        raw_pageview.should be_a_bot_ip

        raw_pageview.ip = 1094151095
        raw_pageview.should be_a_bot_ip

        raw_pageview.ip = 3495458899
        raw_pageview.should_not be_a_bot_ip
      end

    end

    describe 'Searchterm processing' do

      before(:all) do
        @st = Searchterm.new
        @raw_pageview = RawPageviews.new(:id => 1, :session_token => '1', :path => '/', :ip => 3495458900)
      end

      it "should find searchterms in google referer" do

        referer = "http://www.google.com/search?hl=en&ie=ISO-8859-1&q=Equifax+Credit+Watch%99+Gold+with+3-in-1+Monitoring+with+FICO%AE+Score+promotional+code&aq=f&oq=&aqi="
        @st.get_searchterm(referer).should == 'Equifax Credit Watch Gold with 3-in-1 Monitoring with FICO Score promotional code'

        referer = "http://www.google.com/search?q=http%3A%2F%2Fwww.offers.com%2Fblog%2Fpost%2Ffreemakeup-20090423%2F"
        @st.get_searchterm(referer).should == 'http://www.offers.com/blog/post/freemakeup-20090423/'

        referer = 'http://www.google.com/search?hl=en&client=safari&rls=en&as_q=apple+store+promo+code&as_epq=&as_oq=&as_eq=&num=10&lr=&as_filetype=&ft=i&as_sitesearch=&as_qdr=w&as_rights=&as_occt=any&cr=&as_nlo=&as_nhi=&safe=images'
        @st.get_searchterm(referer).should == 'apple store promo code'

      end

      it "should find searchterms in webcrawler referer" do

        referer = "http://www.webcrawler.com/webcrawler104/ws/results/Web/mystery%20guild/1/417/TopNavigation/Relevance/iq=true/zoom=off/_iceUrlFlag=7?_IceUrl=true&s_kwcid=TC-9483-100082-runofcategoryeducation&lsid=876861988-9e2.28f2.4ad37c2c.135d"
        @st.get_searchterm(referer).should == 'mystery guild'

      end

      it "should find searchterms in ask referer" do

        referer = "http://www.ask.com/web?q=sears+coupon&qsrc=2871&o=13173&l=dis"
        @st.get_searchterm(referer).should == 'sears coupon'

      end

      it "should find searchterms in aol referer" do
        referer = 'http://search.aol.com/aol/search?query=carbonite+codes+special+offers&s_it=keyword_rollover'
        @st.get_searchterm(referer).should == 'carbonite codes special offers'

      end

      it "should find searchterms in hp.my.aol referer" do
        referer = 'http://search.hp.my.aol.com/aol/search?invocationType=enus-mh-1_-hp-ws-cn-dt-le&query=sears+grill+coupon'
        @st.get_searchterm(referer).should == 'sears grill coupon'

      end

      it "should find searchterms in yahoo referer" do
        referer = 'http://search.yahoo.com/bin/search?fr=ybr_vzn&p=boden%20coupon%20offer'
        @st.get_searchterm(referer).should == 'boden coupon offer'

      end

      it "should find searchterms in myway referer" do
        referer = 'http://search.myway.com/search/GGmain.jhtml?ptnrS=de&type=w&st=site&searchfor=bose+free+shipping+coupon+code'
        @st.get_searchterm(referer).should == 'bose free shipping coupon code'

      end

      it "should find searchterms in roadrunner referer" do
        referer = 'http://search.rr.com/search?qs=carbonite+backup&source=web'
        @st.get_searchterm(referer).should == 'carbonite backup'

      end

      it "should find searchterms in bing referer" do
        referer = 'http://www.bing.com/search?FORM=DLCDF7&PC=MDDC&q=promo+codes+for+shoplet.com&src=IE-SearchBox'
        @st.get_searchterm(referer).should == 'promo codes for shoplet.com'

      end

      it "should find searchterms in bing referer" do
        referer = 'http://www.bing.com/search?srch=105&FORM=IE7RE&q=offer+codes+for+carbonite'
        @st.get_searchterm(referer).should == 'offer codes for carbonite'

      end

      it "should find searchterms in avantfind referer" do
        referer = 'http://www.avantfind.com/search.asp?keywords=coupon+spyware+doctor'
        @st.get_searchterm(referer).should == 'coupon spyware doctor'

      end

      it "should find searchterms in goodsearch referer" do
        referer = 'http://www.goodsearch.com/search.aspx?keywords=barnes+%26+noble+coupons'
        @st.get_searchterm(referer).should == 'barnes & noble coupons'

      end

      it "should find searchterms in mahalo referer" do
        referer = 'http://www.mahalo.com/bettys-attic-coupons'
        @st.get_searchterm(referer).should == 'bettys attic coupons'

      end

      it "should find searchterms in verizon referer" do
        referer = 'http://wwz.websearch.verizon.net/search?page=2&bm=w&next=Keywords%3Dcontainer%2520store%2520coupons%26xargs%3D12KPjg1g1SsIGmmvmnN%252DmZDrDaoAtP0cHwsd5sCpIIQYgc5XEZUPV9aNqfwIEnELXD3D2SnueXiKILTcOqWMm7UF%255FQHvq9GAfLy%255Fz0%252DIsoNdulTNNBhx8dc9Do0rpOYE81Mz2keqa6v978%26hData%3D12KPjg1o1glcX2u7iqAbu6ROeKwl164ZC38MIaCZEMGKdW9HptUpYKT5Px&qp=container%20store%20coupons&om=w&of=ii23&rn=vaJEgSXZj9Eq2xh&rg=As3f'
        @st.get_searchterm(referer).should == 'container store coupons'

      end

      it "should find searchterms in dogpile referer" do
        referer = 'http://www.dogpile.com/Dogpile_fctb/ws/results/Web/coupon%20codes%20for%20online%20offers/1/0/0/Relevance/iq=true/zoom=off/user_id=19981459/tool_id=60241/_iceUrlFlag=7?_IceUrl=true'
        @st.get_searchterm(referer).should == 'coupon codes for online offers'

      end

      it "should ignore doubleclick referer" do

        referer = "http://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-7150800623600127&dt=1244741640890&lmt=1244741640&output=html&slotname=0397246821&correlator=1244741640718&url=http%3A%2F%2Femol.org%2Fentertainmentbook%2F2009.html&ref=http%3A%2F%2Femol.org%2Fentertainmentbook%2F&frm=0&ga_vid=1966578389.1244741147&ga_sid=1244741147&ga_hid=1546528250&ga_fc=true&flash=10.0.12.36&w=300&h=250&u_h=1024&u_w=1280&u_ah=994&u_aw=1280&u_cd=32&u_tz=-300&u_his=5&u_java=true&dtd=16&xpc=zu7IsqN7bv&p=http%3A//emol.org"
        @st.get_searchterm(referer).should == ''

      end

      it "should ignore offers referer" do
        referer = "http://www.offers.com/?q=ff"
        @st.get_searchterm(referer).should == ''

      end

      it "should find searchterms in referer in raw_pageviews" do

        @raw_pageview.referer = 'http://search.comcast.net/?cat=Web&con=homepage&q=sitstay.com+promo+code'
        @raw_pageview.searchterm.should == 'sitstay.com promo code'

      end



    end
  end
end
