require_relative "../api"
require "rspec"
require "active_support/all"
require "rack/test"


set :environment, :test

describe "The Api" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

before do 
  LogRequest.clear_log!
  LogRequest.log_request(6.seconds.ago.utc, "Hello World", 30.seconds.ago.utc)
end
  it "should return json array of log requests" do
    get "/"
    json = JSON.parse(last_response.body)
    log_request = json.first["logrequest"]
    log_request.fetch("text").should eq("Hello World")


    time_in_utc = Time.parse(log_request.fetch("time"))
    time_in_utc.should be_within(1).of(6.seconds.ago.utc)

    time_in_mars = Time.parse(log_request.fetch("execution_time"))
    time_in_mars.should be_within(1).of(30.seconds.ago.utc)
  end

    it "should post a log" do
    get "/"
    json = JSON.parse(last_response.body)
    count = json.count
    post("/", {time: Time.now, text: 'awesome', execution_time: Time.now, user: '892' })
    json = JSON.parse(last_response.body)
    new_count = json.count
    new_count.should equal(count + 1)
  end
end

describe LogRequest do #variable that will be logged. 

  let(:subject) { LogRequest.new(45.minutes.ago, "Just Record It", 30.minutes.ago, "9220")}

  it "should have the text" do
    subject.text.should eq("Just Record It")
  end
  it "should keep the time" do
    subject.time.should be_within(0.01).of(45.minutes.ago)
  end

  it "should execute the time" do
    subject.execution_time.should be_within(0.01).of(30.minutes.ago)
  end

 describe ":log" do #be able to log something 
   before do
    LogRequest.clear_log!
    LogRequest.log_request(Time.now, "Now", Time.now)
    LogRequest.log_request(Time.now, "Now", Time.now) #be able to send in a period of time when called
  end
   it "should be an array-like thing" do
    LogRequest.log.count.should eq(2)
  end
   it "should request LogRequest" do
     LogRequest.log.first.should be_a(LogRequest)
   end

   it "can clear out the log" do
     LogRequest.clear_log!
     LogRequest.log.should be_empty
   end

 end
end
