optional_require 'net/pop'
optional_require 'tmail'

module ETL
  module Processor
    # Custom processor to download files via Pop3 Attachment
    class Pop3attachmentDownloaderProcessor < ETL::Processor::Processor
      attr_reader :host
      attr_reader :ssl
      attr_reader :port
      attr_reader :delete
      attr_reader :filters
      attr_reader :username
      attr_reader :local_dir
      
      # configuration options include:
      # * host - hostname or IP address of POP3 server (required)
      # * ssl  - activate encryption (default false)
      # * port - port number for POP3 server (default: Net::POP3.default_port or Net::POP3.default_pop3s_port)
      # * delete - delete message after reading (default false)
      # * filters  - filter mails (default [])
      # * username - username for POP3 server authentication (default: anonymous)
      # * password - password for POP3 server authentication (default: nil)
      # * local_dir - local output directory to save downloaded files (default: '')
      #
      def initialize(control, configuration)
        @host = configuration[:host]
        @ssl = configuration[:ssl] || false
        @port = configuration[:port] || (@ssl ? Net::POP3.default_pop3s_port : Net::POP3.default_port )
        @delete = configuration[:delete] || false
        @filters = configuration[:filters] || []
        @username = configuration[:username] || 'anonymous'
        @password = configuration[:password]
        @local_dir = configuration[:local_dir] || ''
      end
      
      def process
        Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE) if @ssl
        conn = Net::POP3.new(@host, @port)
        conn.start(@username, @password)
        if !conn.mails.empty?
          conn.each_mail do |message|
            stringmail = message.pop
            mail = TMail::Mail.parse(stringmail)
            next if mail.attachments.blank?
            if applyfilter(mail, @filters)
              mail.attachments.each do |attachment|
                filename = attachment.original_filename
                File.open(local_file(filename), "w") {|f|
                  f << attachment.gets(nil)
                }
              end

              message.delete if @delete
            end
          end
        end

        conn.finish
      end
      
      private
      attr_accessor :password
      
      def local_file(name)
        File.join(@local_dir, name)
      end

      def applyfilter(mail, cond)
        return true if (cond.nil? or cond.size < 3)

        first = cond[1]
        if (cond[1].class == Array)
          first = eval_condition(row, cond[1])
        end

        second = cond[2]
        if (cond[2].class == Array)
          second = eval_condition(row, cond[2])
        end

        return eval("#{cond[0]}#{first}#{second}") if cond[0] == "!"

        eval("#{first}#{cond[0]}#{second}")
      rescue => e
        return false
      end
    end
  end
end
