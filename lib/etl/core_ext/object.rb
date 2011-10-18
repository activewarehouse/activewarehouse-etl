# patch for https://github.com/activewarehouse/activewarehouse-etl/issues/24
# allow components to require optional gems
module ETL #:nodoc:
  module CoreExt #:nodoc:
    module Object #:nodoc:

      module OptionalRequire #:nodoc:
        def optional_require(feature)
          begin
            require feature
          rescue LoadError
          end
        end

      end
    end
  end
end
