require File.dirname(__FILE__) + '/test_helper'

class EncodeProcessorTest < Test::Unit::TestCase

  SOURCE = 'data/encode_source_latin1.txt'
  TARGET = 'output/encode_destination_utf-8.txt'

  def setup
    @control = flexmock("control")
    @control.should_receive(:file).twice.and_return(File.dirname(__FILE__) + '/fake-control.ctl')
  end
  
  def test_should_transform_a_latin1_file_to_utf8_with_grace
    configuration = { :source_file => SOURCE, :source_encoding => 'latin1', :target_file => TARGET, :target_encoding => 'utf-8' }
    ETL::Processor::EncodeProcessor.new(@control, configuration).process
    assert_equal "éphémère has accents.\nlet's encode them.", IO.read(File.join(File.dirname(__FILE__),TARGET))
  end
  
  def test_should_throw_exception_on_unsupported_encoding
    configuration = { :source_file => SOURCE, :source_encoding => 'acme-encoding', :target_file => TARGET, :target_encoding => 'utf-8' }
    error = assert_raise(ETL::ControlError) { ETL::Processor::EncodeProcessor.new(@control, configuration) }
    assert_equal "Either the source encoding 'acme-encoding' or the target encoding 'utf-8' is not supported", error.message
  end
  
  def test_should_throw_exception_when_target_and_source_are_the_same
    configuration = { :source_file => SOURCE, :source_encoding => 'latin1', :target_file => SOURCE, :target_encoding => 'utf-8' }
    error = assert_raise(ETL::ControlError) { ETL::Processor::EncodeProcessor.new(@control, configuration) }
    assert_equal "Source and target file cannot currently point to the same file", error.message
  end
  
end