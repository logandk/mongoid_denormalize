require "benchmark"
require 'rubygems'
require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("mongoid_denormalize_development")
end

def bm(context = "")
  print("#{context}\t")
  Benchmark.bm do |bm|
    [10, 100, 1000, 10000].each do |i|
      @user = User.create
      i.times do
        @user.articles.create
      end

      bm.report("#{i}\t") do
        @user.update_attributes :name => 'John Doe', :email => 'john@doe.com'
      end

      @user.articles.destroy_all
      @user.delete
    end
  end
end

lib_path = 'lib/mongoid_denormalize.rb'
lib_full_path = File.expand_path("../#{lib_path}", __FILE__)

eval `git show a83c4fc3e86f19f9c494b9f068f3bd44d876db1a:#{lib_path}`
Dir["#{File.dirname(__FILE__)}/spec/app/models/*.rb"].each { |f| require f }
bm "Before"

load lib_full_path
bm "After"
