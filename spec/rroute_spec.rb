require 'rspec'
require 'rack/test'
require 'sinatra/base'
require_relative '../lib/sinatra/rroute'
require_relative 'test_app'


RSpec.configure do |config|
  config.include Rack::Test::Methods
end

describe "Rroute" do
  # Setup

  def app
    TestApp
  end

  before(:each) do
    @user = { :name => 'John', :age => 32}
  end


  # Tests


  describe "#paths" do
    it "merges route mappings into `settings.app_paths' uppon a GET \
request" do
      get '/paths/randomname/randomdescription/'
      paths = {:paths_test_path =>
        {:http_method=>:get,
          :regex =>"/paths/:name/:description/?",
          :controller =>:paths_test,
          :mask =>"/paths/:name/:description/"},
        :route =>
        {:http_method =>:get,
          :regex =>"/route/:name/?",
          :controller =>nil,
          :mask =>"/route/:name"},
        :color =>
        {:http_method =>:get,
          :regex =>"/api/new/color/:name/:value/?",
          :controller =>:show_color,
          :mask =>"/api/new/color/:name/:value"},
        :blue =>
        {:http_method =>:post,
          :regex =>"/important/api/blue/:name/:value/?",
          :controller =>:post_blue,
          :mask =>"/important/api/blue/:name/:value"},
        :something =>
        {:http_method =>:get,
          :regex =>"/something/:name/:value/?",
          :controller =>:api_something,
          :mask =>"/something/:name/:value"}}
      expect(last_response).to be_ok
      expect(last_response.body).to eq(paths.inspect)
    end
  end


  describe "#gget" do
    it "successfully dispatches a GET request and defines a route mask" do
      get "/user/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:user][:mask]).to eq("/user/:name/:age\
/")
      expect(last_response.body).to eq("/user/#{@user[:name]}/\
#{@user[:age]}/")
    end
  end

  describe "#gget (2)" do
    it "successfully dispatches a GET request and defines a route mask
(using a RegExp-quoted string as route)" do
      get "/regex/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(last_response.body).to eq("/regex/#{@user[:name]}/\
#{@user[:age]}/")
    end
  end

  describe "#gget (3)" do
    it "successfully dispatches a GET request and defines a route mask
(using a nested controller reference - instance method)" do
      get '/nested/controller/references'
      expect(last_response).to be_ok
      expect(last_response.body)
        .to include('95475e78-f2c9-11e3-ba43-60eb69544a6d')
    end
  end

  describe "#gget (4)" do
    it "successfully dispatches a GET request and defines a route mask
(using a nested controller reference - class method)" do
      get '/nested/controller/references/another/one'
      expect(last_response).to be_ok
      expect(last_response.body)
        .to include('98985e7e-f2c9-11e3-b9d9-60eb69544a6d')
    end
  end

  describe "#ppost" do
    it "successfully dispatches a POST request and defines a route mask" do
      post "/user/new/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:new_user][:mask]).to eq("/user/new/\
:name/:age/")
      expect(last_response.body).to eq("/user/new/#{@user[:name]}/\
#{@user[:age]}/")
    end
  end

  describe "#pput" do
    it "successfully dispatches a PUT request and defines a route mask" do
      put "/user/change/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:change_user][:mask]).to eq("/user/\
change/:name/:age/")
      expect(last_response.body).to eq("/user/change/#{@user[:name]}/\
#{@user[:age]}/")
    end
  end

  describe "#ddelete" do
    it "successfully dispatches a DELETE request and defines a route \
mask" do
      delete "/user/delete/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:delete_user][:mask]).to eq("/user/\
delete/:name/:age/")
      expect(last_response.body).to eq("/user/delete/#{@user[:name]}/\
#{@user[:age]}/")
    end
  end

  describe "#hhead" do
    it "successfully dispatches a HEAD request and defines a route \
  mask" do
      head "/user/head/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:head_user][:mask]).to eq("/user/\
head/:name/:age/")
      expect(last_response.body).to be_empty
    end
  end

  describe "#ppath" do
    it "successfully dispatches a GET request and defines a route \
mask (using `ppath')" do
      get "/user/moreinfo/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:more_user_info][:mask]).to eq("/user/\
moreinfo/:name/:age/")
      expect(last_response.body).to eq("/user/moreinfo/#{@user[:name]}/\
#{@user[:age]}/")
    end
  end

  describe "#nnampespace" do
    it "successfully dispatches a GET request and defines a route \
mask (using `nnamespace' and `gget')" do
      # /api/v1/beta
      get "/api/v1/beta/user/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:api_user_beta][:mask]).to eq("/api/\
v1/beta/user/:name/:age/")
      expect(last_response.body).to eq("/api/v1/beta/user/#{@user[:name]}/\
#{@user[:age]}/")

      # /api/v1/alpha
      get "/api/v1/alpha/user/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:api_user_alpha][:mask]).to eq("/api/\
v1/alpha/user/:name/:age/")
      expect(last_response.body).to eq("/api/v1/alpha/user/\
#{@user[:name]}/#{@user[:age]}/")

      # `mmap' in a `nnamespace' block
      get "/api/v1/overview/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:api_overview][:mask]).to eq("/api/\
v1/overview/:name/:age/")
      expect(last_response.body).to eq("/api/v1/overview/\
#{@user[:name]}/#{@user[:age]}/")
    end
  end

  describe "#nnampespace (2)" do
    it "successfully dispatches a GET request and defines a route mask \
  (using `nnamespace' and Sinatra's `get', `post', `put' and `delete')" do
      # GET
      get "/user/sinatra/get/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(last_response.body).to eq('User GET')
      # POST
      post "/user/sinatra/post/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(last_response.body).to eq('User POST')
    end
  end

  describe "#mmap" do
    it "successfully dispatches a GET request and defines a route \
mask (using `mmap' and Sinatra's built-in `get')" do
      get "/user/mmap/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:mmap_user][:mask]).to eq("/user/mmap/\
:name/:age/")
      expect(last_response.body).to eq("/user/mmap/#{@user[:name]}/\
#{@user[:age]}/")
    end
  end

  describe "#mmap (2)" do
    it "successfully dispatches a GET request and defines a route \
mask (using `mmap', Sinatra's built-in `get' and a quoted string as route)" do
      get "/user/mmap/regex/#{@user[:name]}/#{@user[:age]}/"
      expect(last_response).to be_ok
      expect(app.settings.app_paths[:mmap_user][:mask]).to eq("/user/mmap/\
:name/:age/")
      expect(last_response.body).to eq("/user/mmap/regex/#{@user[:name]}/\
#{@user[:age]}/")
    end
  end

  describe "#generate_paths" do
    it "successfully dispatches a GET request and generates \
`settings.app_paths')" do
      get '/generate/paths/'
      expect(last_response).to be_ok
      expect(last_response.body).to eq 'Paths have been generated.'
      expect(app.settings.app_paths).not_to be(nil)
    end
  end
end
