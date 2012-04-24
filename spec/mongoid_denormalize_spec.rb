require "spec_helper"

describe Mongoid::Denormalize do
  before(:all) do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
    
    @post = Post.create!(:title => "Blog post", :body => "Lorem ipsum...", :created_at => Time.parse("Jan 1 2010 12:00"))
    @user = User.create!(:name => "John Doe", :email => "john@doe.com", :post => @post, :location => [1, 1])
    @comment = @post.comments.create(:body => "This is the comment", :user => @user)
    @article = @user.articles.create!(:title => "Article about Lorem", :body => "Lorem ipsum...", :created_at => Time.parse("Jan 1 2010 12:00"))

    @user.comments << @comment
    @other_user = User.create!(:name => "Bill")
  end

  context "denormalize from" do
    it "should define multiple fields for association" do
      @post.fields.should have_key "user_name"
      @post.fields.should have_key "user_email"
      @post.fields.should have_key "user_location"
    end
    
    it "should default to string field type for associated fields" do
      @post.fields["user_name"].type.should eql String
    end
    
    it "should allow setting the field type for associated fields" do
      @comment.fields["post_created_at"].type.should eql Time
    end
    
    it "should allow multiple declarations for the same association" do
      @comment.fields.should have_key "user_name"
      @comment.fields.should have_key "user_email"
    end
    
    it "should denormalize fields without specified type" do
      @comment.user_name.should eql @user.name
      @comment.user_email.should eql @user.email
      @post.user_name.should eql @user.name
      @post.user_email.should eql @user.email
    end
    
    it "should denormalize fields with specified type" do
      @comment.post_created_at.should eql @post.created_at
      
      @post.user_location.should eql @user.location
    end
    
    it "should update denormalized values if attribute is changed" do
      @user.update_attributes(:name => "Bob Doe", :location => [4, 4])
      
      @post.user_location.should eql @user.location
      
      @comment.user_name.should eql @user.name
    end
    
    it "should update denormalized values if object is changed" do
      @other_user = User.create!(:name => "Bill", :email => "bill@doe.com")
      
      @comment.user = @other_user
      @comment.save!
      
      @comment.user_name.should eql @other_user.name
      @comment.user_email.should eql @other_user.email
    end
  end
  
  context "denormalize to" do
    it "should push denormalized fields to one-to-one association" do
      @user.name = "Elvis"
      @user.save!
      
      @post.user_name.should eql "Elvis"
    end
    
    it "should push denormalized fields to one-to-many association" do
      @post.created_at = Time.parse("Jan 1 2011 12:00")
      @post.save!
      
      @comment.post_created_at.should eql Time.parse("Jan 1 2011 12:00")
    end

    it "should push denormalized fields to association using inverse_of class name" do
      @user.update_attributes(:name => "Bob Doe", :email => "bob@doe.com")
      @user.save!

      @article.author_name.should eql "Bob Doe"
      @article.author_email.should eql "bob@doe.com"
    end
  end
  
  context "rake task" do
    it "should correct inconsistent denormalizations on regular documents" do
      Post.collection.update({ '_id' => @post.id }, { '$set' => { 'user_name' => 'Clint Eastwood' } })
      
      Rake::Task["db:denormalize"].invoke
      Rake::Task["db:denormalize"].reenable
      
      @post.reload
      @post.user_name.should eql @user.name
    end
    
    it "should correct inconsistent denormalizations on referenced embedded documents" do
      @rake_user = User.create!(:name => "Johnny Depp", :email => "johnny@depp.com")
      @rake_comment = @post.comments.create!(:body => "Depp's comment", :user => @rake_user)
      
      @rake_user.update_attributes!(:name => "J. Depp")
      
      Rake::Task["db:denormalize"].invoke
      Rake::Task["db:denormalize"].reenable
      
      @post.reload
      @post.comments.last.user_name.should eql @rake_user.name
    end
  end
end
