require 'spec_helper'

describe ETL::Batch::Directive do
  let(:bad_directive) { Class.new(ETL::Batch::Directive) }

  let(:file)    { fixture_path('all.ebf') }
  let(:engine)  { ETL::Engine.new }

  let(:batch) { ETL::Batch::Batch.resolve(file, engine) }

  describe "Inheriting from ETL::Batch::Directive" do
    context "When you have not implemented the virtual methods" do
      it 'should raise a RuntimeError (Actually, it should raise a NotImplementedError <-- @todo)' do
        expect {
          bad_directive.new(batch).execute
        }.to raise_error(RuntimeError)
      end
    end
  end

end
