  require 'spec_helper'

  describe Searchlogic::SearchExt::Base do 
  before(:each) do 
    @James = User.create(:name=>"James", :age =>20, :username => "jvans1", :email => "jvannem@gmail.com" )
    @JamesV = User.create(:name=>"James Vanneman", :age =>21, :username => "jvans1")
    @Tren = User.create(:name => "Tren", :age =>11, :username => "Tren")
    @Ben = User.create(:name=>"Ben", :age => 12, :username => "")
  end

  context "#initialize" do
    it "should require a class" do
      lambda { Searchlogic::Search.new }.should raise_error(ArgumentError)
    end

    it "should set the conditions" do
      search = User.search(:username_eq => "bjohnson")
      search.conditions.should eq({:username_eq => "bjohnson"})
    end
  end


  context "#initial_sanitize" do 
    it "ignores nil on mass assignment" do 
      search = User.searchlogic(:username_eq => nil, :name_like =>"James")
      search.conditions.should eq({:name_like => "James"})
      search.count.should eq(2)
      search.map(&:name).should eq(["James", "James Vanneman"])
    end    

    it "raises error when passing unauthorzed scope on mass assignment" do 
      expect {User.search(:age_gt => 26, :unauthorized => "not ok")}.to raise_error
    end 

    it "raises error when passing destructive methods on initialize" do 
      expect{ User.search(:destroy => true)}.to raise_error
    end

    it "should ignore blank strings" do
      User.create(:username => "")
      search = User.search(:conditions => {"username_eq" => ""} )
      search.username_eq.should be_nil
      search = User.search(:name_eq => [])
      search.name_eq.should eq([])
    end

    it "should not ignore blank values in arrays" do
      User.create(:username => "")
      search = User.search("username_equals_any" => [""])
      search.username_equals_any.should eq ""
      search.conditions = {"username_equals_any" => ["", "Tren"]}
      search.conditions.should eq({:username_equals_any => ["", "Tren"]})
    end

    it "converts string keys to symbols" do
      search = User.search("name_eq" => "James")
      search.conditions.should eq({:name_eq => "James"})
      search.name_eq.should eq("James")
    end  
  end

  context "#clone" do
    it "should clone properly" do
      company = Company.create
      user1 = company.users.create(:age => 5)
      user2 = company.users.create(:age => 25)
      search1 = company.users.search(:age_gt => 10)
      search2 = search1.clone
      search2.conditions.should eq(search1.conditions)
      search2.age_gt = 1
      search2.all.should eq([user1, user2])
      search1.all.should eq([user2])
    end

    it "should clone properly without scope" do
      user1 = User.create(:age => 5)
      user2 = User.create(:age => 25)
      search1 = User.search
      search2 = search1.clone
      search2.age_gt = 12
      search2.all.should eq([@James, @JamesV, user2])
      search1.all.should eq(User.all)
    end
  end


end