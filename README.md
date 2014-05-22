# Sinatra-rroute

Sinatra-rroute provides Rails-like routes for Sinatra. A route is has a name, is mapped to a controller-like method and has a mask to be used by the provided `path' helper function. The `path' helper takes the name of a route, a set of keyword-value mappings, applies them to the mask and gives back the route with each keyword replaced by the associated value. Routes can also be namespaced. Namespaces can be nested. There can be multiple namespaces per app.

## Setup

1. Include `sinatra-rroute' in your Gemfile:

        gem 'sinatra-rroute'

2. Require it in your Sinatra app:

        require 'sinatra/rroute'

3. Register it in your app:

        register Sinatra::Rroute

## Usage

### Route Mapping

Mapping routes to controller-like methods works by calling one of the sinatra-rroute mapping methods like so:

        # This will call Sinatra's `get' method behind the scenes.
        gget '/[uU]ser/:name/:age/?' => :user_info, :as =>
          :user, :mask => '/user/:name/:age/'

        # This will call Sinatra's `post' method behind the scenes.
        ppost '/[uU]ser/new/:name/:age/?' => :create_user, :as =>
          :new_user, :mask => '/user/new/:name/:age/'

The above examples will map GET requests for routes matching the RegEx `'/[uU]ser/:name/:age/?'` to the function `user_info` and POST requests to the route matching the RegEx `'/[uU]ser/new/:name/:age/?'` to the function :create_user. The first route can be referenced as `user`, the second one as `new_user`.

Here are all the supported mapping methods and their associated HTTP method (all of them have the same signature described above):


        | Rroute Method | HTTP Method |
        |---------------+-------------|
        | gget          | GET         |
        | ppost         | POST        |
        | pput          | PUT         |
        | ppatch        | PATCH       |
        | hhead         | HEAD        |
        | ddelete       | DELETE      |
        | ooptions      | OPTIONS     |
        | llink         | LINK        |
        | uunlink       | UNLINK      |
        | ttrace        | TRACE       |
        | cconnect      | CONNECT     |

The value and validity of some of those HTTP methods is debatable, but it is nice to have them, nonetheless, in case you might need them one day.

If you do not want to map routes to methods, but still give them names and masks, you can use the `mmap` function in combination with Sinatra's built-in `get`/`post`/`delete`/... functions:

        # Signature: mmap(regex, mask, name)
        get mmap('/u*s*e*r*/:name/?', '/user/:name/', :user_info) do
          # ...
        end

### Namespacing

Sinatra-rroute comes with a `nnamespaces` which takes the name of namespace and a block. Each route specified using of the sinatra-rroute mapping functions (`gget`/`ppost`/`ddelete`/, also `mmap`) inside the block will be prefixed by the specified prefix. Sinatra's built-in `get`/`post`/`delete`/... functions used within a namespace block are *not* affected by the namespacing. Namespaces can be nested. Prefixes do have to specify leading and/or trailing slashes explicitely!

Here is an example:

        nnamespace '/api' do
          nnamespace '/v1' do
            gget '/[uU]ser/:name/:age/?' => :user_info, :as =>
              :user, :mask => '/user/:name/:age/'
        
            ppost '/[uU]ser/new/:name/:age/?' => :create_user, :as =>
              :new_user, :mask => '/user/new/:name/:age/'
          end
        
          gget '/documentation/?' => :api_documentation, :as =>
            :api_docs, :mask => '/documentation/'
        end


### Route Helper

Sinatra-rroute comes with a `path` helper function. It takes the name of a route and a hash of key-value mappings and returns the path for that route according to its mask. Each "token" in a mask will be replaced by the value for the specified key in the mapping.

        # Specify a route mapping.
        gget '/[uU]ser/:name/:age/?' => :user_info, :as =>
          :user, :mask => '/user/:name/:age/'

        # Redirect to this route.
        get '/friend/:name/:age/?' do
          redirect to(path(:user, :name => params[:name], :age => params[:age]))
        end
        
        # Generate a link for the route in the view.
        <a href="<%= path(:user, :name => 'John', :age => 32) %>">Get user info</a>
        # This will render the following link:
        #   <a href="/user/John/32/">Get user info</a>

The helper can be used in your view files as well as in your controller/model/application. It is handy for links, redirecting etc.

### Accessing Routes

The full hash of all route-method mappings is attached to your Sinatra app's `settings` object available through the `settings.app_paths` variable.

*Note*: The full list of all of all routes is only available after the last call of one of the sinatra-rroute mapping methods, of course.

*Note*: When mixing sinatra-rroute mapping functions (`gget`/`ppost`/`delete`/`mmap`/...) and Sinatra's built-in `get`/`post`/`delete`/... the routes defined using the Sinatra built-ins will *not* show up in `settings.app_paths`!

## Mixing With Sinatra and Other Extensions

Sinatra's built-in `get`/`post`/`delete`/... functions as well as other route-related extensions do work fine in combination with sinatra-rroute as long as they do not

- clash with rroute's function names,
- fiddle with the `settings.app_paths` variable of your Sinatra app or
- redefine/overload Sinatra's built-in `get`/`post`/`delete` functions without letting sinatra-rroute know.

## *What about the weird names?*

The names are

- concise (as short as possible),
- consistent (same name generatiion scheme) and
- unobtrusive (they do not interfere with or overload Sinatra's and Rack's built-in routing methods, they also do not interfere with other Sinatra extensions).

