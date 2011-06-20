optional_require 'net/sftp'

module ETL
  module Processor
    # Custom processor to download files via SFTP
    class SftpDownloaderProcessor < ETL::Processor::Processor
      attr_reader :host
      attr_reader :port
      attr_reader :remote_dir
      attr_reader :files
      attr_reader :username
      attr_reader :local_dir
      
      # configuration options include:
      # * host - hostname or IP address of FTP server (required)
      # * port - port number for FTP server (default: 22)
      # * remote_dir - remote path on FTP server (default: /)
      # * files - list of files to download from FTP server (default: [])
      # * username - username for FTP server authentication (default: anonymous)
      # * password - password for FTP server authentication (default: nil)
      # * local_dir - local output directory to save downloaded files (default: '')
      # 
      # As an example you might write something like the following in your control process file:
      #  pre_process :sftp_downloader, {
      #    :host => 'sftp.sec.gov',
      #    :path => 'edgar/Feed/2007/QTR2',
      #    :files => ['20070402.nc.tar.gz', '20070403.nc.tar.gz', '20070404.nc.tar.gz', 
      #               '20070405.nc.tar.gz', '20070406.nc.tar.gz'],
      #    :local_dir => '/data/sec/2007/04',
      #  }
      # The above example will anonymously download via SFTP the first week's worth of SEC filing feed data
      # from the second quarter of 2007 and download the files to the local directory +/data/sec/2007/04+.
      def initialize(control, configuration)
        @host = configuration[:host]
        @port = configuration[:port] || 22
        @remote_dir = configuration[:remote_dir] || '/'
        @files = configuration[:files] || []
        @username = configuration[:username] || 'anonymous'
        @password = configuration[:password]
        @local_dir = configuration[:local_dir] || ''
      end
      
      def process
        Net::SFTP.start(@host, @username, {:port => @port, :password => @password}) do |conn|
          @files.each do |f|
            conn.download!(remote_file(f), local_file(f))
          end
        end
      end
      
      private
      attr_accessor :password
      
      def local_file(name)
        File.join(@local_dir, name)
      end
      
      def remote_file(name)
        File.join(@remote_dir, name)
      end
    end
  end
end
