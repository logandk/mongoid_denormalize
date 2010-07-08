require "spec_helper"

describe Mongoid::Denormalize do
  before(:all) do
    Mongoid.master.collections.each do |c|
      c.drop rescue nil
    end
    
    @user = User.create!(:name => "John Doe", :email => "john@doe.com")
    @post = Post.create!(:title => "Blog post", :body => "Lorem ipsum...", :created_at => Time.parse("Jan 1 2010 12:00"), :user => @user)
    @comment = Comment.create!(:body => "This is the comment", :post => @post, :user => @user)
  end

  context "denormalize associated object" do
    it "should define multiple fields for association" do
      @post.fields.should have_key "user_name"
      @post.fields.should have_key "user_email"
    end
    
    it "should override the name of the denormalized field" do
      @comment.fields.should have_key "from_email"
    end
    
    it "should default to string field type for associated fields" do
      @post.fields["user_name"].type.should eql String
    end
    
    it "should allow setting the field type for associated fields" do
      @comment.fields["post_created_at"].type.should eql Time
    end
    
    it "should allow multiple declarations for the same association" do
      @comment.fields.should have_key "user_name"
      @comment.fields.should have_key "from_email"
    end
    
    it "should denormalize fields without specified type" do
      @comment.user_name.should eql @user.name
      @comment.from_email.should eql @user.email
      @post.user_name.should eql @user.name
      @post.user_email.should eql @user.email
    end
    
    it "should denormalize fields with specified type" do
      @comment.post_created_at.should eql @post.created_at
    end
  end
  
  context "denormalization with block" do
    it "should accept block for denormalization" do
      @post.fields.should have_key "comment_count"
    end
    
    it "should accept multiple fields for block" do
      @user.fields.should have_key "post_titles"
      @user.fields.should have_key "post_dates"
    end
    
    it "should allow setting the field type" do
      @user.fields["post_titles"].type.should eql Array
      @post.fields["comment_count"].type.should eql Integer
    end
    
    it "should denormalize fields using block" do
      @post.save!
      @post.comment_count.should eql 1
      
      @user.save!
      @user.post_titles.should eql ["Blog post"]
      @user.post_dates.should eql [Time.parse("Jan 1 2010 12:00") + 300]
    end
  end
end