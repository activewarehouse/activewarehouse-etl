module ETL #:nodoc: 
  module Transform #:nodoc:
    # Transform which walks up the hierarchy tree to find a value of the current level's value
    # is nil.
    #
    # TODO: Let the resolver be implemented in a class so different resolution methods are
    # possible.
    class HierarchyLookupTransform < ETL::Transform::Transform
      # The name of the field to use for the parent ID
      attr_accessor :parent_id_field
      
      # The target connection name
      attr_accessor :target
      
      # Initialize the transform
      #
      # Configuration options:
      # * <tt>:target</tt>: The target connection name (required)
      # * <tt>:parent_id_field</tt>: The name of the field to use for the parent ID (defaults to :parent_id)
      def initialize(control, name, configuration={})
        super
        @parent_id_field = configuration[:parent_id_field] || :parent_id
        @target = configuration[:target]
      end
      
      # Transform the value.
      def transform(name, value, row)
        if parent_id = row[parent_id_field]
          # TODO: should use more than just the first source out of the control
          parent_id, value = lookup(name, 
            control.sources.first.configuration[:table], parent_id, parent_id_field)        
          until value || parent_id.nil?
            # TODO: should use more than just the first source out of the control
            parent_id, value = lookup(name, 
              control.sources.first.configuration[:table], parent_id, parent_id_field)
          end
        end
        value
      end
      
      # Lookup the parent value.
      def lookup(field, table, parent_id, parent_id_field)
        q = "SELECT #{parent_id_field}, #{field} FROM #{table} WHERE id = #{parent_id}"
        row = ETL::Engine.connection(target).select_one(q)
        return row[parent_id_field.to_s], row[field.to_s]
      end
    end
  end
end