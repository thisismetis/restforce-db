module Restforce

  module DB

    module Associations

      # Restforce::DB::Associations::BelongsTo defines a relationship in which
      # a Salesforce ID on the named database association exists on this
      # Mapping's Salesforce record.
      class BelongsTo < Base

        # Public: Construct a database record from the Salesforce records
        # associated with the supplied parent Salesforce record.
        #
        # database_record   - An instance of an ActiveRecord::Base subclass.
        # salesforce_record - A Hashie::Mash representing a Salesforce object.
        #
        # Returns an Array of constructed association records.
        def build(database_record, salesforce_record)
          lookups = {}
          attributes = {}
          instances = []

          for_mappings(database_record) do |mapping, lookup|
            lookup_id = salesforce_record[lookup]
            lookups[mapping.lookup_column] = lookup_id
            instance = mapping.salesforce_record_type.find(lookup_id)

            # If any of the mappings are invalid, short-circuit the creation of
            # the associated record.
            return [] unless instance

            instances << instance
            attrs = mapping.convert(mapping.database_model, instance.attributes)
            attributes = attributes.merge(attrs)
          end

          associated = association_scope(database_record).find_by(lookups)
          associated ||= database_record.association(name).build(lookups)

          associated.assign_attributes(attributes)
          nested = instances.flat_map { |i| nested_records(database_record, associated, i) }

          [associated, *nested]
        end

        private

        # Internal: Iterate through all relevant mappings for the target
        # ActiveRecord class.
        #
        # database_record - An instance of an ActiveRecord::Base subclass.
        #
        # Yields the Restforce::DB::Mapping and the corresponding String lookup.
        # Returns nothing.
        def for_mappings(database_record)
          Registry[target_class(database_record)].each do |mapping|
            lookup = lookup_field(mapping, database_record)
            next unless lookup
            yield mapping, lookup
          end
        end

        # Internal: Get the Salesforce ID belonging to the associated record
        # for a supplied instance. Must be implemented per-association.
        #
        # instance - A Restforce::DB::Instances::Base
        #
        # Returns a String.
        def associated_salesforce_id(instance)
          reflection = instance.mapping.database_model.reflect_on_association(name)
          inverse_association = association_for(reflection)

          salesforce_instance = instance.mapping.salesforce_record_type.find(instance.id)
          salesforce_instance.record[inverse_association.lookup] if salesforce_instance
        end

      end

    end

  end

end