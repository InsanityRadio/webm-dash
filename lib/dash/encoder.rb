module DASH
	class Encoder

		autoload :Configuration, 'dash/encoder/configuration'

		autoload :FFmpeg, 'dash/encoder/ffmpeg'
		include DASH::Dispatch

		HEAD_EXTENSION = "h"
		CHUNK_EXTENSION = ".w"

		attr_reader :c, :current_chunk


		#encoder, input, path, prefix, extension, history, chunk_length
		def initialize c, current_chunk = nil

			@c = c

			@gc = GarbageCollector.new @c.path, @c.prefix, CHUNK_EXTENSION, @c.history, @c.chunk_length

			@gc.add_listener DASH::Event::NewChunk, &method(:on_new_chunk)

			current_chunk = Time.now.to_i.to_s if current_chunk == nil
			@current_chunk = current_chunk

			prefix = "#{@c.path}/#{@c.prefix}"
			@encoder = @c.encoder.new @c.input, @c.chunk_length, @c.bitrate, @c.codec

			$threads << (@thread = Thread.new { loop {
				@encoder.start! @current_chunk, "#{prefix}%d#{CHUNK_EXTENSION}", "#{prefix}0.#{HEAD_EXTENSION}"
				DASH.logger.error("Encoder quit. Restarting it.")

				dispatch DASH::Event::Crash.new, @current_chunk += 1, self
			}})

		end	

		private
		def on_new_chunk event, latest_chunk, time, caller

			@current_chunk = latest_chunk
			@gc.collect! @current_chunk

			dispatch event, latest_chunk, time, caller

		end

	end
end