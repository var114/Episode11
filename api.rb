require 'rubygems'
require 'bundler'
Bundler.require

require 'sinatra'
require 'active_support/all'

Rabl.register!


class LogRequest
attr_reader :text, :time, :execution_time
  def initialize(time, text, execution_time)
    @text = text
    @time = time
    @execution_time = execution_time
  end

  @@log = []
  def self.log_request(time, text, execution_time)
    @@log << LogRequest.new(time, text, execution_time)
  end 

  def self.log
    @@log
  end

  def self.clear_log!
   @@log = []
  end
end

LogRequest.log_request(Time.now, "Do it", "EXECUTE")


get '/' do
  @logs = LogRequest.log
  render :rabl, :logs, :format => "json"

end

   