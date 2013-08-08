$:.unshift "."
require 'lib/db'


describe DB do
    before(:all) do 
        @db = DB.new "test.db"
        @user_data = {
            :id => "test",
            :pw => "me",
            :sno => "20111111",
            :mail => "asdefe@asdf.com",
            :name => "asdf",
            :ip => "123.123.123.123"
        }

        @prob_data = {
            :title => "test",
            :category => "crypto",
            :author => "test",
            :body => "body",
            :auth => "authkey",
            :score => 500,
            :file => nil
        }

        @mail = {:mail => @user_data[:mail]}
    end

    it "should create database correctly" do
        @db = DB.new "test.db"
        @db.should_not == nil
    end

    it "should check params before insert new user" do
        prev = @user_data[:mail]
        @user_data[:mail] = nil
        @db.insert_user(@user_data).should == -1
        @user_data[:mail] = prev
    end

    it "should insert new user data correctly" do
        @db.insert_user(@user_data).should == 1
    end

    it "should check if user id already exists" do
        @db.insert_user(@user_data).should == 0
    end

    it "should check if user mail already exists" do
        prev = @user_data[:id]
        @user_data[:id] = "asdf"
        @db.insert_user(@user_data).should == 0
        @user_data[:id] = prev
    end

    it "should check params before insert new problem" do
        prev = @prob_data[:score]
        @prob_data[:score] = nil
        @db.insert_prob(@prob_data).should == -1
        @prob_data[:score] = prev
    end

    it "should insert new problem data corrently" do
        @db.insert_prob(@prob_data).should == 1
    end

    it "should check if problem title already exists" do
        @db.insert_prob(@prob_data).should == 0
    end

    it "should login correctly with given id and pw" do
        @db.check_login(@user_data).should == 1

        prev = @user_data[:id]
        @user_data[:id] = "asdfa"
        @db.check_login(@user_data).should == 0
        @user_data[:id] = prev
    end

    it "should check if mail is valid for recovery" do
        prev = @mail[:mail]
        @mail[:mail] = "aaaa@aaaa.com"
        @db.check_mail(@mail).should == 0
        @mail[:mail] = prev

        @db.check_mail(@mail).should == 1
    end

    after(:all) do 
        `rm test.db`
    end
end


