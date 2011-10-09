require 'spec_helper'

describe ETL::Batch do
  let(:file)      { fixture_path('all.ebf') }
  let(:engine)    { ETL::Engine.new }

  describe '#resolve' do
    context "Valid Arguments" do
      context "When given a file name" do
        it "should not raise an error" do
          expect {
            batch = ETL::Batch.resolve(file, engine)
            batch.execute
          }.to_not raise_exception
        end
      end

      context "When given an IO-descendant object" do
        it "should not raise an error" do
          expect {
            batch = ETL::Batch.resolve(File.new(file), engine)
            batch.execute
          }.to_not raise_exception
        end
      end

      context "When given a Batch object" do
        it "should not raise an error" do
          expect {
            batch_instance = ETL::Batch.new(File.new(file))
            batch_instance.engine = engine

            batch = ETL::Batch.resolve(batch_instance, engine)
            batch.execute
          }.to_not raise_exception
        end
      end
    end

    context "Invalid Arguments" do
      it "should raise an exception" do
        expect {
          ETL::Batch.resolve(0, engine)
        }.to raise_exception(RuntimeError)
      end
    end
  end

end
