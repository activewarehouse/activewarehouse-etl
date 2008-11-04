module ETL #:nodoc:
  module Processor #:nodoc:
    # A processor which requires that the particular fields are non-blank in
    # order for the row to be retained.
    class RequireNonBlankProcessor < ETL::Processor::RowProcessor
      # An array of fields to check
      attr_reader :fields
      
      # Initialize the processor
      #
      # Options:
      # * <tt>:fields</tt>: An array of fields to check, for example:
      #   [:first_name,:last_name]
      def initialize(control, configuration)
        super
        @fields = configuration[:fields] || []
      end
      
      # Process the row.
      def process(row)
        fields.each { |field| return if row[field].blank? }
        row
      end
    end
  end
end