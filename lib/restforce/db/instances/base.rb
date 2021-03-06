module Restforce

  module DB

    module Instances

      # Restforce::DB::Instances::Base defines common behavior for the other
      # models defined in the Restforce::DB::Instances namespace.
      class Base

        attr_reader :record, :record_type, :mapping

        # Public: Initialize a new Restforce::DB::Instances::Base instance.
        #
        # record_type - A String or Class describing the record's type.
        # record      - The Salesforce or database record to manage.
        # mapping     - An instance of Restforce::DB::Mapping.
        def initialize(record_type, record, mapping = nil)
          @record_type = record_type
          @record = record
          @mapping = mapping
        end

        # Public: Update the instance with the passed attributes.
        #
        # attributes - A Hash mapping attribute names to values.
        #
        # Returns self.
        # Raises if the update fails for any reason.
        def update!(attributes)
          return self if attributes.empty?

          record.update!(attributes)
          after_sync
        end

        # Public: Get a Hash mapping the configured attributes names to their
        # values for this instance.
        #
        # Returns a Hash.
        def attributes
          @mapping.attributes(@record_type, record)
        end

        # Public: Has this record been synced with Salesforce?
        #
        # Returns a Boolean.
        def synced?
          true
        end

        # Public: A hook which is performed after records are synchronized.
        # Override this method in subclasses to inject generic behaviors into
        # the record synchronization flow.
        #
        # Returns self.
        def after_sync
          self
        end

      end

    end

  end

end
