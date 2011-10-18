module CustomMatchers
  class BeWellFormed
    attr_writer :errors

    def errors
      @errors ||= []
    end

    def matches?(files)
      self.errors = files.dup

      errors.map! do |filename|
        file = File.read(filename).encode!("UTF-8")

        next unless file.valid_encoding?

        [ check_for_tabs(filename, file), excessive_spacing(filename, file), newline_precedes_eof(filename, file) ]
      end

      errors.flatten!
      errors.compact!

      errors.empty?
    end

    def failure_message_for_should
      errors.join("\n")
    end

    def check_for_tabs(filename, file)
      bad_lines = file.lines.each_with_index.map do |line, line_no|
                    line_no + 1 if line["\t"] and line !~ /^\s+#.*\s+\n$/
                  end.flatten.compact

      "#{filename} has tab characters on lines #{bad_lines.join(', ')}" if bad_lines.any?
    end

    def excessive_spacing(filename, file)
      bad_lines = file.lines.each_with_index.map do |line, line_no|
                    line_no + 1 if line =~ /\s+\n$/ and line !~ /^\s+#.*\s+\n$/
                  end.flatten.compact

      "#{filename} has spaces on the EOL on lines #{bad_lines.join(', ')}" if bad_lines.any?
    end

    def newline_precedes_eof(filename, file)
      "#{filename} does not have a newline (\\n) before EOF" if file !~ /\n$/
    end
  end

  def be_well_formed
    BeWellFormed.new
  end
end
