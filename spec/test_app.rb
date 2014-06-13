require 'sinatra'
require_relative '../lib/sinatra/rroute'

class TestApp < Sinatra::Base
  register Sinatra::Rroute

  # `paths'

  gget '/paths/:name/:description/?' => :paths_test, :as =>
    :paths_test_path, :mask => '/paths/:name/:description/'

  paths({:route =>
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
            :mask =>"/something/:name/:value"}})
  @@merged_paths = settings.app_paths.dup

  def paths_test
    @@merged_paths.inspect
  end

  def show_color
    '#FF0000'
  end

  def post_blue
    'This is a blue post.'
  end

  def api_something
    'API...'
  end

  #########################################################################
  # NOTE
  #
  # For the tests to work correctly do not define more routes above this
  # point in the file or modify `settings.app_paths' in any other way
  # without also adjusting the `paths' variable in the `#paths' RSpec block
  # in `rroute_integration_spec.rb'!
  #########################################################################


  # GET

  gget '/user/:name/:age/?' => :do_show_user_info, :as =>
    :user, :mask => '/user/:name/:age/'

  def do_show_user_info
    path :user, :name => params[:name], :age => params[:age]
  end

  # GET (using a RegExp-quoted string as route)

  gget %r{/regex/:name/:age/?} => :show_regex, :as =>
    :regex, :mask => '/regex/:name/:age/'

  def show_regex
    path :regex, :name => params[:name], :age => params[:age]
  end

  # POST

  ppost '/user/new/:name/:age/?' => :do_create_new_user, :as =>
    :new_user, :mask => '/user/new/:name/:age/'

  def do_create_new_user
    path :new_user, :name => params[:name], :age => params[:age]
  end

  # PUT

  pput '/user/change/:name/:age/?' => :do_change_user, :as =>
    :change_user, :mask => '/user/change/:name/:age/'

  def do_change_user
    path :change_user, :name => params[:name], :age => params[:age]
  end

  # DELETE

  ddelete '/user/delete/:name/:age/?' => :do_delete_user, :as =>
    :delete_user, :mask => '/user/delete/:name/:age/'

  def do_delete_user
    path :delete_user, :name => params[:name], :age => params[:age]
  end

  # HEAD

  hhead '/user/head/:name/:age/?' => :do_head_user, :as =>
    :head_user, :mask => '/user/head/:name/:age/'

  def do_head_user
    # Because this is a controller method for a HEAD request, the following
    # response should NOT be sent! This is default Sinatra behavior.
    path :head_user, :name => params[:name], :age => params[:age]
  end

  # GET (using `ppath')

  ppath({'/user/moreinfo/:name/:age/?' =>
          :show_more_user_info}, :get, :as => :more_user_info, :mask =>
        '/user/moreinfo/:name/:age/')

  def show_more_user_info
    path :more_user_info, :name => params[:name], :age => params[:age]
  end

  # GET (using `nnamespace' and `gget')

  nnamespace '/api' do
    nnamespace '/v1' do
      nnamespace '/beta' do
        gget '/user/:name/:age/?' => :api_do_show_user_info_beta, :as =>
          :api_user_beta, :mask => '/user/:name/:age/'

        def api_do_show_user_info_beta
          path :api_user_beta, :name => params[:name], :age => params[:age]
        end
      end

      nnamespace '/alpha' do
        gget '/user/:name/:age/?' => :api_do_show_user_info_alpha, :as =>
          :api_user_alpha, :mask => '/user/:name/:age/'

        def api_do_show_user_info_alpha
          path :api_user_alpha, :name => params[:name], :age =>
            params[:age]
        end
      end

      get mmap('/overview/:name/:age/?', '/overview/:name/:age/',
               :api_overview) do
        path :api_overview, :name => params[:name], :age => params[:age]
      end
    end
  end

  nnamespace '/api' do
    nnamespace '/v1' do
      nnamespace '/beta' do
        get '/user/sinatra/get/:name/:age/?' do
          'User GET'
        end

        post '/user/sinatra/post/:name/:age/?' do
          'User POST'
        end
      end
    end
  end

  # GET (using `mmap' and Sinatra's built-in `get')

  get mmap('/user/mmap/:name/:age/?', '/user/mmap/:name/:age/',
           :mmap_user) do
    path :mmap_user, :name => params[:name], :age => params[:age]
  end

  # GET (using `mmap', Sinatra's built-in `get' and a quoted string as
  # route)

  get mmap(%r{/user/mmap/regex/([\w]+)/([\w]+)/?},
           '/user/mmap/regex/:name/:age/', :mmap_regex_user) do |name, age|
    path :mmap_regex_user, :name => name, :age => age
  end

  # `generate_paths'

  # Callign `mmap' invokes `generate_paths' and registers a new route.
  # Consequence: `settings.app_paths' cannot be `nil' anymore. This is
  # what the test can test check.
  get mmap('/generate/paths/?', 'generate/paths/', :build_paths) do
    'Paths have been generated.'
  end

  # Nested controller references

  require 'controllers/init'

  # Instance method
  gget '/nested/controller/references' =>
    'TestApp::Nested::Controller::Reference#controller', :as =>
    :nested_controller_reference, :mask => '/nested/controller/references'

  # Class method
  gget '/nested/controller/references/another/one' =>
    'TestApp::Nested::Controller::Reference::another_controller', :as =>
    :another_nested_controller_reference, :mask =>
    '/nested/controller/references/another/one'
end
