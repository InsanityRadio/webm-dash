$LOAD_PATH << File.dirname(__FILE__)
require 'time'
require 'logger'

module DASH
	autoload :Event, 'dash/event'
	autoload :Dispatch, 'dash/dispatch'

	autoload :WEBM, 'dash/webm'
	autoload :GarbageCollector, 'dash/garbage_collector'
	autoload :Manifest, 'dash/manifest'

	autoload :Encoder, 'dash/encoder'

	autoload :Controller, 'dash/controller'
	autoload :Server, 'dash/server'


	module Error
		autoload :InvalidEventError, 'dash/error/invalid_event_error'
	end

	class Event
		autoload :Crash, 'dash/event/crash'
		autoload :NewChunk, 'dash/event/new_chunk'
	end

	def self.logger
		@@logger ||= Logger.new STDOUT
	end
end