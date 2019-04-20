require 'yaml'

require File.dirname(__FILE__) + '/test_helper'

include ETL::Processor

class Pop3attachmentDownloaderProcessorTest < Test::Unit::TestCase

  should 'return the attachment of the first mail' do
    credentials = YAML::load( File.open( './test/config/mail.yml' ) )

    dirname = './test/output/pop3/'

    FileUtils.rm_rf(dirname)
    Dir.mkdir(dirname)

    Pop3attachmentDownloaderProcessor.new(nil,
       :host => "pop.gmail.com",
       :ssl => true,
       :port => 995,
       :delete => false,
       :filters => [],
       :username => credentials["gmail"]["username"],
       :password => credentials["gmail"]["password"],
       :local_dir => dirname,
       :number_mails => 1
       ).process
    assert_equal true, ((Dir.new(dirname).entries.size - 2) > 0)
  end
  
end
