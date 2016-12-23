module DASH
	module Dispatch

		attr_reader :listeners

		def add_listener event = nil, &listener

			raise DASH::Error::InvalidEventError, "#{event} is not an Event" \
				unless event.nil? or event.ancestors.include? DASH::Event
			@listeners = [] if !defined? @listeners
			@listeners << [event, listener]

		end

		def dispatch event, *args, caller
			raise DASH::Error::InvalidEventError, "#{event} is not an Event" \
				unless event.is_a? DASH::Event

			event.args = args
			event.caller = caller

			return if !defined? @listeners

			@listeners.each do | l |
				l[1].call(event, *args, caller) if l[0].nil? or event.class.ancestors.include?(l[0])
			end

		end

	end
end