require 'spec_helper'

describe Site do

  context "stringification" do
    it "uses the specified name if available" do
      site = FactoryGirl.build(:site, :name => 'AwesomeGarden')
      site.to_s.should eq "AwesomeGarden"
    end
    it "falls back to the address" do
      site = FactoryGirl.build(:site,
        :name => nil,
        :address => 'foo',
        :suburb => 'bar'
      )
      site.to_s.should eq "foo, bar"
    end
  end

  context "geocoding" do
    it 'has a full address' do
      address = "1 Smith St"
      suburb = "Smithville"
      Acres::Application.config.region = "Smithlandia"
      site = FactoryGirl.create(:site, :address => address, :suburb => suburb)
      site.full_address.should eq "1 Smith St, Smithville, Smithlandia"
    end
  end

  context "required fields" do
    it 'address is required' do
      site = FactoryGirl.build(:site)
      site.should be_valid
      site = FactoryGirl.build(:site, :address => nil)
      site.should_not be_valid
    end

    it 'suburb is required' do
      site = FactoryGirl.build(:site)
      site.should be_valid
      site = FactoryGirl.build(:site, :suburb => nil)
      site.should_not be_valid
    end

    context 'status' do
      before(:each) do
        @site = FactoryGirl.create(:site)
      end

      it 'should have a status' do
        @site.status.should eq 'unknown'
      end

      it 'all valid status values should work' do
        ['unknown', 'unsuitable', 'potential', 'proposed', 'active'].each do |s|
          @site = FactoryGirl.build(:site, :status => s)
          @site.should be_valid
        end
      end

      it 'should refuse invalid status values' do
        @site = FactoryGirl.build(:site, :status => 'not valid')
        @site.should_not be_valid
        @site.errors[:status].should include("not valid is not a valid status")
      end
    end
  end

  context "website" do
    it 'validates website' do
      @site = FactoryGirl.build(:site, :website => 'http://example.com')
      @site.should be_valid
      @site = FactoryGirl.build(:site, :website => 'example.com')
      @site.should be_valid
    end
    it 'allows blank and nil website' do
      @site = FactoryGirl.build(:site, :website => '')
      @site.should be_valid
      @site = FactoryGirl.build(:site, :website => nil)
      @site.should be_valid
    end
    it 'normalises website if http is missing' do
      @site = FactoryGirl.build(:site, :website => 'example.com')
      @site.should be_valid
      @site.website.should eq 'http://example.com'
    end
    it "doesn't normalise websites starting with http" do
      @site = FactoryGirl.build(:site, :website => 'http://example.com')
      @site.should be_valid
      @site.website.should eq 'http://example.com'
    end
    it "doesn't normalise websites starting with https" do
      @site = FactoryGirl.build(:site, :website => 'https://example.com')
      @site.should be_valid
      @site.website.should eq 'https://example.com'
    end
    it "doesn't normalise blank website" do
      @site = FactoryGirl.build(:site, :website => '')
      @site.should be_valid
      @site.website.should eq ''
    end
    it "doesn't normalise nil website" do
      @site = FactoryGirl.build(:site, :website => nil)
      @site.should be_valid
      @site.website.should eq nil
    end
  end

  context 'watches' do
    before(:each) do
      @site = FactoryGirl.create(:site)
    end

    it "can watch a site" do
      expect {
        FactoryGirl.create(:watch, :site => @site)
      }.to change { @site.watches.count}.by(1)
    end

    it "auto-watches site when added by a non-admin" do
      @user = FactoryGirl.create(:user)
      @this_site = FactoryGirl.create(:site, :added_by_user => @user)
      @this_site.watches.count.should == 1
      @this_site.watches.last.user.should eq @user
    end

    it "auto-watches site when added by an admin" do
      @admin_user = FactoryGirl.create(:admin_user)
      @new_site = FactoryGirl.create(:site, :added_by_user => @admin_user)
      @new_site.watches.count.should == 1
      @new_site.watches.last.user.should eq @admin_user
    end
  end

end
