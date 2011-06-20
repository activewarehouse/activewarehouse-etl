module ETL #:nodoc:
  module Transform #:nodoc:
    # Transform which looks up the value and replaces it with a foriegn key reference
    class ForeignKeyLookupTransform < ETL::Transform::Transform
      # The resolver to use if the foreign key is not found in the collection
      attr_accessor :resolver
      
      # The default foreign key to use if none is found.
      attr_accessor :default
      
      # Initialize the foreign key lookup transform.
      #
      # Configuration options:
      # *<tt>:collection</tt>: A Hash of natural keys mapped to surrogate keys. If this is not specified then
      #  an empty Hash will be used. This Hash will be used to cache values that have been resolved already
      #  for future use.
      # *<tt>:resolver</tt>: Object or Class which implements the method resolve(value)
      # *<tt>:default</tt>: A default foreign key to use if no foreign key is found
      # *<tt>:cache</tt>: If true and the resolver responds to load_cache, load_cache will be called
      def initialize(control, name, configuration={})
        super
        
        @collection = (configuration[:collection] || {})
        @resolver = configuration[:resolver]
        @resolver = @resolver.new if @resolver.is_a?(Class)
        @default = configuration[:default]
        
        configuration[:cache] = true if configuration[:cache].nil?
        
        if configuration[:cache]
          if resolver.respond_to?(:load_cache)
            resolver.load_cache
          else
            ETL::Engine.logger.info "#{resolver.class.name} does not support caching"
          end
        end
      end
      
      # Transform the value by resolving it to a foriegn key
      def transform(name, value, row)
        fk = @collection[value]
        unless fk
          raise ResolverError, "Foreign key for #{value} not found and no resolver specified" unless resolver
          raise ResolverError, "Resolver does not appear to respond to resolve method" unless resolver.respond_to?(:resolve)
          fk = resolver.resolve(value)
          fk ||= @default
          raise ResolverError, "Unable to resolve #{value} to foreign key for #{name} in row #{ETL::Engine.rows_read}. You may want to specify a :default value." unless fk
          @collection[value] = fk
        end
        fk
      end
    end
    # Alias class name for the ForeignKeyLookupTransform.
    class FkLookupTransform < ForeignKeyLookupTransform; end
  end
end

# Resolver which resolves using ActiveRecord.
class ActiveRecordResolver
  # The ActiveRecord class to use
  attr_accessor :ar_class
  
  # The find method to use (as a symbol)
  attr_accessor :find_method
  
  # Initialize the resolver. The ar_class argument should extend from 
  # ActiveRecord::Base. The find_method argument must be a symbol for the 
  # finder method used. For example:
  # 
  # ActiveRecordResolver.new(Person, :find_by_name)
  #
  # Note that the find method defined must only take a single argument.
  def initialize(ar_class, find_method)
    @ar_class = ar_class
    @find_method = find_method
  end
  
  # Resolve the value
  def resolve(value)
    rec = ar_class.__send__(find_method, value)
    rec.nil? ? nil : rec.id
  end
end

class SQLResolver
  # Initialize the SQL resolver. Use the given table and field name to search
  # for the appropriate foreign key. The field should be the name of a natural
  # key that is used to locate the surrogate key for the record.
  #
  # The connection argument is optional. If specified it can be either a symbol
  # referencing a connection defined in the ETL database.yml file or an actual
  # ActiveRecord connection instance. If the connection is not specified then
  # the ActiveRecord::Base.connection will be used.
  def initialize(atable, afield, connection=nil)
    # puts "table: #{atable.inspect} field:#{afield.inspect}"
    @table = atable
    @field = afield
    @connection = (connection.respond_to?(:quote) ? connection : ETL::Engine.connection(connection)) if connection
    @connection ||= ActiveRecord::Base.connection
  end
  
  def resolve(value)
    return nil if value.nil?
    r = nil
    if @use_cache
      r = cache[value]
      # puts "resolve failed: #{value.class.name}:#{value.inspect} from: #{@table}.#{@field}" unless r
    else
      q = "SELECT id FROM #{table_name} WHERE #{wheres(value)}"
      # puts q
      r = @connection.select_value(q)
    end
    r
  end
  
  def table_name
    ETL::Engine.table(@table, @connection)
  end
  
  def cache
    @cache ||= {}
  end
  
  def load_cache
    q = "SELECT id, #{field.join(', ')} FROM #{table_name}"
    # puts q
    @connection.select_all(q).each do |record|
      ck = @field.kind_of?(Array) ? record.values_at(*@field) : record[@field]
      # puts "load_cache key: #{ck.class.name}:#{ck.inspect}"
      # puts "  #{@field.class.name}:#{@field.inspect}"
      # puts "  #{record[@field].class.name}:#{record[@field].inspect}"
      cache[ck] = record['id']
    end
    @use_cache = true
  end

  private

  def field
    if @field.kind_of?(Array)
      @field
    else
      [ @field ]
    end
  end

  def wheres(value)
    value  = [ value ]  unless value.kind_of?(Array)
    field.zip(value).collect { |a|
      "#{a[0]} = #{@connection.quote(a[1])}"
    }.join(' AND ')
  end
end

class IncrementalCacheSQLResolver < SQLResolver

  def initialize(atable, afield, connection=nil)
    super
  end
  
  def resolve(value)
    return nil if value.nil?
    r = cache[value]
    unless r
      q = "SELECT id FROM #{table_name} WHERE #{wheres(value)}"
      r = @connection.select_value(q)
      if r
        cache[value] = r
      end
    end
    r
  end

  def load_cache
    @cache = {}
  end

end

class FlatFileResolver
  # Initialize the flat file resolver. Expects to open a comma-delimited file. 
  # Returns the column with the given result_field_index.
  #
  # The matches argument is a Hash with the key as the column index to search and
  # the value of the Hash as a String to match exactly. It will only match the first
  # result.
  def initialize(file, match_index, result_field_index)
    @file = file
    @match_index = match_index
    @result_field_index = result_field_index
  end
  
  # Get the rows from the file specified in the initializer.
  def rows
    @rows ||= CSV.read(@file)
  end
  protected :rows
  
  # Match the row field from the column indicated by the match_index with the given 
  # value and return the field value from the column identified by the result_field_index.
  def resolve(value)
    rows.each do |row|
      #puts "checking #{row.inspect} for #{value}"
      if row[@match_index] == value
        #puts "match found!, returning #{row[@result_field_index]}"
        return row[@result_field_index]
      end
    end
    nil
  end
end
