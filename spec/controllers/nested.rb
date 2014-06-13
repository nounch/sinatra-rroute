class TestApp < Sinatra::Base

  module Nested
    class Controller
      class Reference
        def controller
          'I am nested controller. 95475e78-f2c9-11e3-ba43-60eb69544a6d'
        end

        def self.another_controller
          'I am also nested 98985e7e-f2c9-11e3-b9d9-60eb69544a6d'
        end
      end
    end
  end

end
