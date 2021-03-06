module Sinatra
  module Rroute
    private
    def self.registered(app)
      app.set :app_paths, {}
      app.set :app_prefixes, []
      app.helpers do
        # @!visibility public
        #
        # Return a path for a given route mask.
        #
        # @param [String] name The name of a route for which a mask has
        #   been specified.
        # @param [Hash{Symbol=>Object}] options Hash of Symbol tokens to be
        #   replaced by the associated value. The token (symbol) has to
        #   have the exact name specified in the mask for this route.
        #
        # @example
        #
        #   # The mask for this route has been defined like this:
        #   #   gget '/[uU]ser/:name/:age/?' => :user_info, :as =>
        #   #     user, :mask => '/user/:name/:age/'
        #   path :user, :name => 'John', :age => 32
        #   # => '/user/John/32/'
        #
        #
        # @return [String] Path for the specified route. Every token for
        #   this route is replaced by the specified value in `options'.
        def path(name, *options)
          keywords = options[0]
          # Take the last string as path mask.
          # (Important: Make a duplicate. Do not reference the original
          # mask/regex in `settings.app_paths'!)
          path = settings.app_paths[name.to_sym][:mask].dup ||
            settings.app_paths[name.to_sym][:regex].dup
          if keywords != nil
            keywords.each do |keyword, value|
              path.gsub! /:#{keyword.to_s}/, value.to_s
            end
          end
          path
        end

        # @visibility private
        #
        # Take the string representation of a nested instance method or of
        # a class method and call the method.
        #
        # Notes:
        #
        # - The name is chosen to be long and unique enough to not be
        #   accidentially overwritten
        # - Arguments are not supported as the methods to use this function
        #   on are controllers.
        # - Unlike the `:to' option of Rails' `match' method (used by
        #   `get'/`post'/...), strings are case-sensitive.
        # - Unlike the `:to' option of Rails' `match' method
        #   methods can be arbitrarily deeply nested.
        #
        # @param [String] string String representation of a method
        #
        # @example
        #
        #   # Instance method
        #   rroute_call_nested_controller_from_string(
        #     'Very::Deeply::Nested#controller')
        #
        #   # Class method
        #   rroute_call_nested_controller_from_string(
        #     'Very::Deeply::Nested::controller')
        #
        # @return [nil] Nothing.
        def rroute_call_nested_controller_from_string(string)
          method_sep = '#'
          nesting_sep = '::'
          if string =~ %r{#{method_sep}}
            tokens = string.split(method_sep)
            const = Kernel.const_get(tokens[0])
            method = tokens[-1]
            const.new.send(method.to_sym)
          else
            tokens = string.split(nesting_sep)
            const = Kernel.const_get(tokens[0..-2].join(nesting_sep))
            method = tokens[-1]
            const.send(method.to_sym)
          end
        end
      end
    end

    public

    # @!visibility public
    #
    # Merge paths into `settings.app_paths' which holds all paths defined
    # for the app.
    #
    # @param [Hash{Symbol=>Hash}] paths Paths to be merged into
    #   `settings.app_paths'. The hash has to have the structure outlined
    #   below.
    #
    # @example
    #
    #   paths({:route =>
    #           {:http_method =>:get,
    #             :regex =>"/route/:name/?",
    #             :controller =>nil,
    #             :mask =>"/route/:name"},
    #           :color =>
    #           {:http_method =>:get,
    #             :regex =>"/api/new/color/:name/:value/?",
    #             :controller =>:show_color,
    #             :mask =>"/api/new/color/:name/:value"},
    #           :blue =>
    #           {:http_method =>:post,
    #             :regex =>"/important/api/blue/:name/:value/?",
    #             :controller =>:post_blue,
    #             :mask =>"/important/api/blue/:name/:value"},
    #           :something =>
    #           {:http_method =>:get,
    #             :regex =>"/something/:name/:value/?",
    #             :controller =>:api_something,
    #             :mask =>"/something/:name/:value"}})
    #
    # @return [nil] Nothing.
    def paths(paths)
      settings.app_paths.merge! paths
      generate_paths
    end


    # @!visibility public
    #
    # Define a route mapping a path to a controller with a HTTP method, a
    # name and a mask for route generation.
    #
    # @param [Hash{String=>Symbol}] mapping Mapping of a route RegEx to a
    #   controller function.
    # @param [Symbol] http_method The HTTP method used for this route
    #   (`:get', `post', `patch', ...)
    # @param [Hash] options Optional: Options for this mapping. Allowed
    #   values: `:as => :route_name', `:mask => "/mask/for/route/:value/"'
    #
    # @example
    #
    #   ppath({'/[Pp]ost?/info/:id/?' => :post_info}, :get, :as =>
    #     :post, :mask => '/post/:info/')
    #
    # @return [nil] Nothing.
    def ppath(mapping, http_method, *options)
      options = options[0]
      prefix = settings.app_prefixes.empty? ? '' :
        settings.app_prefixes.join
      controller = nil
      if mapping.values[0] != nil
        # controller = mapping.values[0].to_sym
        controller = mapping.values[0]
      end
      if mapping.keys[0].class == Regexp
        mapping_regex = mapping.keys[0]
      else
        mapping_regex = Regexp.new(mapping.keys[0])
      end
      settings.app_paths.merge!({options[:as].to_sym => {
                                    :http_method => http_method || :get,
                                    :regex => %r{#{prefix}\
#{mapping_regex.source}} || Regexp.new(''),
                                    :controller => controller,
                                    :mask => prefix + options[:mask]}}) ||
        ''
      generate_paths
    end

    # @!visibility public
    # @!method gget(mapping, *options)
    #
    #   Map a request using the HTTP GET method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     gget '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    # @!visibility public
    # @!method ppost(mapping, *options)
    #
    #   Map a request using the HTTP POST method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     ppost '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    # @!visibility public
    # @!method pput(mapping, *options)
    #
    #   Map a request using the HTTP PUT method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     pput '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    # @!visibility public
    # @!method ppatch(mapping, *options)
    #
    #   Map a request using the HTTP PATCH method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     ppatch '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    # @!visibility public
    # @!method hhead(mapping, *options)
    #
    #   Map a request using the HTTP HEAD method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     hhead '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    # @!visibility public
    # @!method ddelete(mapping, *options)
    #
    #   Map a request using the HTTP DELETE method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     ddelete '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    # @!visibility public
    # @!method ooptions(mapping, *options)
    #
    #   Map a request using the HTTP OPTIONS method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     ooptions '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    # @!visibility public
    # @!method llink(mapping, *options)
    #
    #   Map a request using the HTTP LINK method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     llink '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    # @!visibility public
    # @!method uunlink(mapping, *options)
    #
    #   Map a request using the HTTP UNLINK method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     uunlink '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    # @!visibility public
    # @!method ttrace(mapping, *options)
    #
    #   Map a request using the HTTP TRACE method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     ttrace '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    # @!visibility public
    # @!method cconnect(mapping, *options)
    #
    #   Map a request using the HTTP CONNECT method to a controller method.
    #
    #   @param [Hash] mapping Mapping from a route RegEx to a controller
    #     function.
    #   @param [Hash] options Optional: Options for this route. Allowed
    #     values: `:as => :route_name',
    #     `:mask => "/mask/for/route/:value/"'
    #
    #   @example
    #
    #     cconnect '/[Uu]sers?/:name/:age/?' => :user_info, :as =>
    #       :user, :mask => '/user/:name/:args/'
    #
    #   @return [nil] Nothing.

    {:gget => :get,
      :ppost => :post,
      :pput => :put,
      :ppatch => :patch,
      :hhead => :head,
      :ddelete => :delete,
      :ooptions => :options,
      :llink => :link,
      :uunlink => :unlink,
      :ttrace => :trace,
      :cconnect => :connect}.each do |method_name, http_method|
      define_method method_name do |options|
        # Do some `magic'/hacking to get the same `get' route drawer method
        # interface that Rails has. People are used to it/get to get used
        # to it quickly.
        key = (options.keys - [:as, :regex, :controller, :mask])[0]
        ppath({key => options[key]}, http_method, options)
      end
    end

    # @!visibility public
    #
    # Map a route RegEx to a controller method with a name and a mask for
    # path generation.
    #
    # Since this method is meant to be used together with Sinatra's
    # built-in `get'/`post'/`patch'/... mapper methods, it does not to
    # map the route to a controller function since this would bypass
    # Sinatra's built-in mapper method.
    #
    # @param [String] regex Route RegEx.
    # @param [String] mask Mask for route generation.
    # @name [Symbol] name Name to reference this route for route generation
    #   etc.
    #
    # @example
    #
    #   get mmap('/[Uu]ser/:name/:age/?', '/user/:name/:age/', :user) do
    #     # ...
    #   end
    #
    # @return [nil] Nothing.
    def mmap(regex, mask, name)
      options = {}
      options[:regex] = regex
      options[:mask] = mask
      options[:as] = name
      options[:controller] = nil
      ppath({regex => nil}, nil, options)

      # Prepend the prefix to the returned RegExp.
      mapping_regex = regex == Regexp ? regex : Regexp.new(regex)
      prefix = settings.app_prefixes.empty? ? '' :
        settings.app_prefixes.join
      output = %r{#{prefix}#{mapping_regex.source}}.source ||
        Regexp.new('')
      # Return the right type of object depending on the input.
      regex.class == Regexp ? Regexp.new(output) : output
    end

    # @!visibility public
    #
    # Generate all route mappings from the paths in `settings.app_paths'.
    #
    # @return [nil] Nothing.
    def generate_paths
      settings.app_paths.each do |name, value|
        if value[:controller] != nil
          # Paths merged using `paths' should be allowed to to be specified
          # as strings. So they have to be converted here.
          if value[:regex].class != Regexp
            value[:regex] = Regexp.new(value[:regex])
          end
          # Adapt the RegEx representation.
          value[:regex] = value[:regex].source
          send(value[:http_method],
               value[:regex]) do
            if value[:controller].class == Symbol
              send value[:controller]
            else
              rroute_call_nested_controller_from_string(value[:controller]
                                                          .to_s)
            end
          end
        end
      end
    end

    # @!visibility public
    #
    # Namespace a all routes defined within the given block using the
    # mapping methods `gget'/`ppost'/`ppatch'/...
    #
    # Sinatra's built-in mapping methods `get'/`post'/`patch' are NOT
    # affected by the namespacing.
    #
    # @param [String] prefix Namespace to be used. HAS to include leading
    #   and/or trailing slashes!
    # @yield [] Block containing route mapping method calls
    #   (`gget'/`ppost'/`ppatch'/...) and/or other relevant application
    #   code. Can also include calls to Sinatra's built-in mapping methods
    #   (`get'/`post'/`patch'/...) which will not be affected by the
    #   namespacing.
    #
    # @return [nil] Nothing.
    def nnamespace(prefix, &block)
      settings.app_prefixes << prefix
      block.call
      settings.app_prefixes.pop
    end
  end
  register Rroute
end
