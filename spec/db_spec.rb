$:.unshift "."
require 'pages/db'


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
    end

    it "should create database correctly" do
        @db = DB.new "test.db"
        @db.should_not == nil
    end

    it "should check params before insert" do
        @db.check_params("user", @user_data).should == true

        @user_data[:mail] = nil
        @db.check_params("user", @user_data).should == false

        @user_data[:mail] = "asdf@asdf.com"
        @db.check_params("user", @user_data).should == true

        @prob_data[:score] = nil
        @db.check_params("prob", @prob_data).should == false

        @prob_data[:score] = 500
        @db.check_params("prob", @prob_data).should == true
    end

    it "should insert new user data correctly" do
        @db.insert_user(@user_data).should == true
    end

    it "should check if user id already exists" do
        @db.insert_user(@user_data).should == false
    end

    it "should insert new problem data corrently" do
        @db.insert_prob(@prob_data).should == true
    end

    it "should check if problem title already exists" do
        @db.insert_prob(@prob_data).should == false
    end

    it "should login correctly with given id and pw" do
        @db.check_login(@user_data).should == true

        @user_data[:id] = "aa"
        @db.check_login(@user_data).should == false
    end

    after(:all) do 
        `rm test.db`
    end
end


