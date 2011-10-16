# This source file contains the ETL::Processor class and autoloads all of the built-in processors
module ETL #:nodoc:
  # The ETL::Processor class contains row-level and bulk processors
  # Base class for pre and post processors. Subclasses must implement the +process+ method.
  class Processor
    attr_accessor :control, :configuration

    autoload :BlockProcessor,                     'etl/processor/block_processor'
    autoload :BulkImportProcessor,                'etl/processor/bulk_import_processor'
    autoload :CheckExistProcessor,                'etl/processor/check_exist_processor'
    autoload :CheckUniqueProcessor,               'etl/processor/check_unique_processor'
    autoload :CopyFieldProcessor,                 'etl/processor/copy_field_processor'
    autoload :DatabaseJoinProcessor,              'etl/processor/database_join_processor'
    autoload :EncodeProcessor,                    'etl/processor/encode_processor'
    autoload :EnsureFieldsPresenceProcessor,      'etl/processor/ensure_fields_presence_processor'
    autoload :EscapeCsvProcessor,                 'etl/processor/escape_csv_processor'
    autoload :FilterRowProcessor,                 'etl/processor/filter_row_processor'
    autoload :FtpDownloaderProcessor,             'etl/processor/ftp_downloader_processor'
    autoload :FtpUploaderProcessor,               'etl/processor/ftp_uploader_processor'
    autoload :HierarchyExploderProcessor,         'etl/processor/hierarchy_exploder_processor'
    autoload :ImapattachmentDownloaderProcessor,  'etl/processor/imapattachment_downloader_processor'
    autoload :Pop3attachmentDownloaderProcessor,  'etl/processor/pop3attachment_downloader_processor'
    autoload :PrintRowProcessor,                  'etl/processor/print_row_processor'
    autoload :RenameProcessor,                    'etl/processor/rename_processor'
    autoload :RequireNonBlankProcessor,           'etl/processor/require_non_blank_processor'
    autoload :RowProcessor,                       'etl/processor/row_processor'
    autoload :SequenceProcessor,                  'etl/processor/sequence_processor'
    autoload :SftpDownloaderProcessor,            'etl/processor/sftp_downloader_processor'
    autoload :SftpUploaderProcessor,              'etl/processor/sftp_uploader_processor'
    autoload :SurrogateKeyProcessor,              'etl/processor/surrogate_key_processor'
    autoload :TruncateProcessor,                  'etl/processor/truncate_processor'
    autoload :ZipFileProcessor,                   'etl/processor/zip_file_processor'

    def initialize(control, configuration)
      self.control = control
      self.configuration = configuration
      after_initialize if respond_to?(:after_initialize)
    end

    # Get the engine logger
    def log
      Engine.logger
    end
  end
end

# @todo: Autoload this and spit out a deprecation warning.
ETL::Processor::Processor = ETL::Processor
