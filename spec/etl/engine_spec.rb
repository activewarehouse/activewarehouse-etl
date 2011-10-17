require 'spec_helper'

describe ETL::Engine do
  let(:engine)  { ETL::Engine.new }
  let(:subject) { engine }

  describe '.process' do
    it 'should raise an error when a file which does not exist is given' do
      expect {
        ETL::Engine.process('i-do-not-exist.ctl')
      }.to raise_exception(Errno::ENOENT, "No such file or directory - i-do-not-exist.ctl")
    end

    # @todo: This spec is not useful.
    # @todo: If we are going to enforce requirements on file extension, it should allow .rb.
    #         ie, permit either *.ctl.rb or *.ctl, etc. Or just don't care, and allow any file.
    pending 'should raise an error when an unknown file type is given' do
      expect {
        ETL::Engine.process(fixture_path('data/delimited.txt'))
      }.to raise_exception(RuntimeError)
    end

    its(:errors) { should have(0).items }

    pending 'should stop as soon as the error threshold is reached' do
      engine.process ETL::Control::Control.parse_text(<<-CTL)
        set_error_threshold 1
        source :in, { :type => :enumerable, :enumerable => (1..100) }
        after_read { |row| raise "Failure" }
      CTL

      engine.errors.size.should be 1
    end

  end

  describe '.connection' do
    it 'should return an ActiveRecord configuration by name' do
      ETL::Engine.connection(:data_warehouse).should be_present
    end

    it 'should raise an error on non existent connection' do
      expect {
        ETL::Engine.connection(:does_not_exist)
      }.to raise_exception(ETL::ETLError, "Cannot find connection named :does_not_exist")
    end

    it 'should raise an error when requesting a connection with no name' do
      expect {
        ETL::Engine.connection("  ")
      }.to raise_exception(ETL::ETLError, "Connection with no name requested. Is there a missing :target parameter somewhere?")
    end
  end

  describe 'Temporary Tables' do
    let(:connection) { ETL::Engine.connection(:data_warehouse) }

    it 'should return unmodified table name when temp tables are disabled' do
      ETL::Engine.table('foo', connection).should == 'foo'
    end

    # @todo: This test sucks.
    context "When using temporary tables is set to true" do
      before(:all){ ETL::Engine.use_temp_tables = true  }
      after(:all) { ETL::Engine.use_temp_tables = false }

      it 'should return temp table name instead of table name when temp tables are enabled' do
        connection.should_receive(:copy_table).with('people', 'tmp_people')

        ETL::Engine.table('people', connection).should == 'tmp_people'
      end
    end
  end

  describe 'Integrations' do
    context "When using a single delimited file as the source" do
      let(:delimited_ctl)     { fixture_path('delimited.ctl') }
      let(:delimited_outfile) { File.readlines(fixture_path('output/delimited.txt')) }

      it "should process the control file with no errors" do
        expect {
          ETL::Engine.process(delimited_ctl)
        }.to_not raise_exception
      end

      it "should write all lines, from the source, to the destination" do
        ETL::Engine.process(delimited_ctl)

        delimited_outfile.should have(3).items
      end

      it "should write each record, to the destination, as described in the control file" do
        ETL::Engine.process(delimited_ctl)

        delimited_outfile.map! { |line| line.split(',') }

        delimited_outfile.each_with_index do |record, index|
          record.should have(8).items
          record.first.should == (index + 1).to_s

          expect {
            Time.parse record.last
          }.to_not raise_exception
        end
      end
    end
  end
end
