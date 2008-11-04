source :in, { :type => :mock, :name => :block_input } 

before_write { |row| row[:obsolete] == true ? nil : row }

destination :out, { :type => :mock, :name => :block_output  }