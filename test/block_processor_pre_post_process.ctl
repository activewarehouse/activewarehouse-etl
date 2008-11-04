source :in, { :type => :mock, :name => :another_input } 
pre_process { TestWitness.call("I'm called from pre_process") }
post_process { TestWitness.call("I'm called from post_process") }
destination :out, { :type => :mock, :name => :another_output  }