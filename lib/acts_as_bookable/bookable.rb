module ActsAsBookable
  module Bookable

    def bookable?
      false
    end

    ##
    # Make a model bookable
    #
    # Example:
    #   class Room < ActiveRecord::Base
    #     acts_as_bookable
    #   end
    def acts_as_bookable(**opts)
      bookable(**opts)
    end

    private

    # Make a model bookable
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

      include Core
    end
  end
end
