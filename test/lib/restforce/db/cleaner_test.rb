require_relative "../../../test_helper"

describe Restforce::DB::Cleaner do

  configure!
  mappings!

  let(:cleaner) { Restforce::DB::Cleaner.new(mapping) }

  describe "#run", vcr: { match_requests_on: [:method, VCR.request_matchers.uri_without_param(:q)] } do
    let(:attributes) do
      {
        "Name"             => "Are you going to Scarborough Fair?",
        "Example_Field__c" => "Parsley, Sage, Rosemary, and Thyme.",
      }
    end
    let(:salesforce_id) { Salesforce.create!(salesforce_model, attributes) }

    describe "given a synchronized Salesforce record" do
      before do
        database_model.create!(salesforce_id: salesforce_id)
      end

      describe "when the mapping has no conditions" do
        before do
          cleaner.run
        end

        it "does not drop the synchronized database record" do
          expect(database_model.last).to_not_be_nil
        end
      end

      describe "when the record meets the mapping conditions" do
        before do
          mapping.conditions = ["Name = '#{attributes['Name']}'"]
          cleaner.run
        end

        it "does not drop the synchronized database record" do
          expect(database_model.last).to_not_be_nil
        end
      end

      describe "when the record does not meet the mapping conditions" do
        before do
          mapping.conditions = ["Name != '#{attributes['Name']}'"]
        end

        describe "for a non-Passive strategy" do
          before do
            cleaner.run
          end

          it "drops the synchronized database record" do
            expect(database_model.last).to_be_nil
          end
        end
      end
    end
  end
end
