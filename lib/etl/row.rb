# This source file contains the ETL::Row class.

module ETL #:nodoc:
  # This class represents a single row currently passing through the ETL pipeline
  class Row < Hash
    # Accessor for the originating source
    attr_accessor :source
    
    # All change types
    CHANGE_TYPES = [:insert, :update, :delete]
    
    # Accessor for the row's change type
    attr_accessor :change_type
    
    # Get the change type, defaults to :insert
    def change_type
      @change_type ||= :insert
    end
  end
end