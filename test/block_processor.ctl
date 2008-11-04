source :in, { :type => :mock, :name => :block_processed_input } 

after_read { |row| row[:added_by_after_read] = "after-" +row[:first_name]; row }
before_write { |row| row[:added_by_before_write] = "Row #{Engine.current_source_row}"; [row,{:new_row => 'added by post_processor'}] }

destination :out, { :type => :mock, :name => :block_processed_output  }