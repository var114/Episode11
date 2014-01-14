require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra'
require 'active_support/all'

Rabl.register!


class LogRequest
attr_reader :text, :time, :execution_time, :user
  def initialize(time, text, execution_time, user)
    @text = text
    @time = time
    @execution_time = execution_time
    @user = user
  end

  @@log = []
  def self.log_request(time, text, execution_time, user=nil)
    if (user == nil)
    @@log << LogRequest.new(time, text, execution_time, user=nil)
  else
    @@log << LogRequest.new(time, text, execution_time, user)
    end
  end 

  def self.log
    @@log
  end

  def self.log_user(id)
    @@log.select { |i| i.user == id }
  end

  def self.clear_log!
   @@log = []
  end
end

LogRequest.log_request(Time.now, "Do it", Time.now, '81910')


get '/' do
  if params != {}
    puts "params: #{params}"
    @logs = LogRequest.log_user(params.fetch("user"))
  else
    @logs = LogRequest.log
  end
  render :rabl, :logs, :format => "json"

end

post '/' do
  LogRequest.log_request params.fetch("time"), params.fetch("text"), params.fetch("execution_time"), params.fetch("user")
  @logs = LogRequest.log
  render :rabl, :logs, :format => "json"
  #insert the record into the inner memory store
end