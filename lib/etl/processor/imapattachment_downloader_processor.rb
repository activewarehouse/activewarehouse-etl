optional_require 'net/imap'
optional_require 'tmail'

module ETL
  module Processor
    # Custom processor to download files via Imap Attachment
    class ImapattachmentDownloaderProcessor < ETL::Processor::Processor
      attr_reader :host
      attr_reader :ssl
      attr_reader :port
      attr_reader :delete
      attr_reader :filters
      attr_reader :folder
      attr_reader :username
      attr_reader :local_dir
      
      # configuration options include:
      # * host - hostname or IP address of IMAP server (required)
      # * ssl  - activate encryption (default false)
      # * port - port number for IMAP server (default: 220 or 993)
      # * delete - delete message after reading (default false)
      # * filters  - filter mails (default [])
      # * folder  - folder to select mails from (default INBOX)
      # * username - username for IMAP server authentication (default: anonymous)
      # * password - password for IMAP server authentication (default: nil)
      # * local_dir - local output directory to save downloaded files (default: '')
      #
      def initialize(control, configuration)
        @host = configuration[:host]
        @ssl = configuration[:ssl] || false
        @port = configuration[:port] || (@ssl ? 993 : 220 )
        @delete = configuration[:delete] || false
        @filters = configuration[:filters] || []
        @folder = configuration[:folder] || 'INBOX'
        @username = configuration[:username] || 'anonymous'
        @password = configuration[:password]
        @local_dir = configuration[:local_dir] || ''
      end
      
      def process
        conn = Net::IMAP.new(@host, @port, @ssl)
        conn.login(@username, @password)

        conn.select(@folder)
        conn.uid_search(["NOT", "DELETED"]).each do |msguuid|
          mail = TMail::Mail.parse( conn.uid_fetch(msguuid, 'RFC822').first.attr['RFC822'] )
          next if mail.attachments.blank?
          if applyfilter(mail, @filters)
            mail.attachments.each do |attachment|
              filename = attachment.original_filename
              File.open(local_file(filename), "w") {|f|
                f << attachment.gets(nil)
              }
            end

            conn.store(msguuid, "+FLAGS", [:Deleted]) if @delete
          end
        end
        conn.expunge
        conn.close
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
