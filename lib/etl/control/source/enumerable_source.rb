module ETL #:nodoc:
  class Control #:nodoc:
    # Use an Enumerable as a source
    class EnumerableSource < ETL::Control::Source
      # Iterate through the enumerable
      def each(&block)
        configuration[:enumerable].each(&block)
      end
    end
  end
end
