module ETL #:nodoc:
  module Processor #:nodoc:
    # Row-level processor that will convert a single row into multiple rows designed to be inserted
    # into a hierarchy bridge table.
    class HierarchyExploderProcessor < ETL::Processor::RowProcessor
      attr_accessor :id_field
      attr_accessor :parent_id_field
      
      # Initialize the processor
      #
      # Configuration options:
      # * <tt>:connection</tt>: The ActiveRecord adapter connection
      # * <tt>:id_field</tt>: The name of the id field (defaults to 'id')
      # * <tt>:parent_id_field</tt>: The name of the parent id field (defaults to 'parent_id')
      #
      # TODO: Allow resolver to be implemented in a customizable fashion, i.e. don't rely
      # on AR as the only resolution method.
      def initialize(control, configuration={})
        @id_field = configuration[:id_field] || 'id'
        @parent_id_field = configuration[:parent_id_field] || 'parent_id'
        super
      end
  
      # Process the row expanding it into hierarchy values
      def process(row)
        rows = []
        target = configuration[:target]
        table = configuration[:table]
        conn = ETL::Engine.connection(target)
        build_rows([row[:id]], row[:id], row[:id], row[:parent_id].nil?, 0, rows, table, conn)
        rows
      end
  
      protected
      # Recursive function that will add a row for the current level and then call build_rows
      # for all of the children of the current level
      def build_rows(ids, parent_id, row_id, root, level, rows, table, conn)
        ids.each do |id|
          child_ids = conn.select_values("SELECT #{id_field} FROM #{table} WHERE #{parent_id_field} = #{id}")
      
          row = {
            :parent_id => row_id, 
            :child_id => id, 
            :num_levels_from_parent => level, 
            :is_bottom => (child_ids.empty? ? 1 : 0),
            :is_top => (root ? 1 : 0),
          }
          rows << row
      
          build_rows(child_ids, id, row_id, false, level + 1, rows, table, conn)
        end
      end
    end
  end
end