# lib/acts_as_bookable/bookable.rb
module ActsAsBookable
  module Bookable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_bookable_RENAMED(**opts)
        bookable(**opts)
      end

      private

      def bookable(**opts)
        unless respond_to?(:booking_opts)
          class_attribute :booking_opts
        end

        self.booking_opts = opts

        return if bookable? # already configured

        class_eval do
          serialize :schedule, IceCube::Schedule

          has_many :bookings, as: :bookable, dependent: :destroy, class_name: '::ActsAsBookable::Booking'

          validates_presence_of :schedule, if: :schedule_required?
          validates_presence_of :capacity, if: :capacity_required?
          validates_numericality_of :capacity, if: :capacity_required?, only_integer: true, greater_than_or_equal_to: 0

          def self.bookable?
            true
          end

          def schedule_required?
            booking_opts && booking_opts[:time_type] != :none
          end

          def capacity_required?
            booking_opts && booking_opts[:capacity_type] != :none
          end
        end

        include ActsAsBookable::Bookable::Core
      end
    end

    # fallback for when the model hasn't been initialized as bookable
    def bookable?
      false
    end
  end
end
