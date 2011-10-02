# patch for https://github.com/activewarehouse/activewarehouse-etl/issues/24
# allow components to require optional gems
class Object
  def optional_require(feature)
    begin
      require feature
    rescue LoadError
    end
  end
end
