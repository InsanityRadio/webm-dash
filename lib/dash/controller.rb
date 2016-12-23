module DASH
	class Controller

		include DASH::Dispatch

		def initialize config

			@config = config
			@encoders = []

			@audio_path = @config["root"] + "a/"
			#encode! @config["video"]
			@now = Time.now.to_i.to_s

			@manifest = Manifest.new @config, @config["root"] + "stream.mpd", @now
			self.add_listener DASH::Event::NewChunk, &@manifest.method(:on_new_chunk)
			encode! @audio_path, @config["audio"]

			@manifest.update!

			# we should probably generate a stream here

		end

		private
		def encode! path, spec

			input = spec["source"]
			bitrates = spec["bitrates"]

			bitrates.each do | b | 

				prefix = "#{b}_"

				encoder_config = Encoder::Configuration.new input, path, prefix, @config["history"], @config["chunk_length"]

				encoder_config.source = spec["source"]
				encoder_config.encoder = Object.const_get(spec["encoder"])
				encoder_config.codec = spec["codec"]
				encoder_config.bitrate = b

				DASH.logger.debug("Creating new Encoder, bitrate #{b}, #{spec["encoder"]}")

				encoder = Encoder.new(encoder_config, @now)
				encoder.add_listener DASH::Event::NewChunk, &method(:on_new_chunk)
				encoder.add_listener DASH::Event::Crash, &method(:on_crash)


				@encoders << encoder
				@manifest.add_encoder encoder_config

			end

		end

		def on_new_chunk event, latest_chunk, time, caller

			#@manifest.update! latest_chunk, time, caller
			DASH.logger.debug("New chunk created by Encoder! #{latest_chunk}")
			dispatch event, latest_chunk, time, caller

		end

		def on_crash event, latest_chunk, caller
			$start = Time.now
			@manifest.reset! latest_chunk
		end

	end
end