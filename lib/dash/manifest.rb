require 'erb'
require 'ostruct'

module DASH
	class Manifest

		def initialize config, path, start_chunk

			@config = config
			@path = path
			@start_chunk = start_chunk.to_i
			@encoder_configs = []

		end

		def add_encoder encoder

			@encoder_configs << encoder

		end

		def update! latest_chunk = nil

			latest_chunk = @start_chunk if latest_chunk.nil?
			File.write(@path, render_manifest(latest_chunk.to_i))
			DASH.logger.debug("Updated config file")

		end

		def reset! latest_chunk

			raise "Don't do this. "
			@start_chunk = latest_chunk
			update! latest_chunk

		end

		private

		def render_manifest latest_chunk

			#elapsed = [Time.now.to_i - $start.to_i, @config["history"] / 1000].min
			#start_chunk = [@start_chunk, latest_chunk - (@config["history"] / @config["chunk_length"])].max
			elapsed = Time.now.to_i - $start.to_i
			start_chunk = @start_chunk
			variables = {
				:config => @config,
				:history => elapsed,
				:start_chunk => start_chunk,
				:start_time => (Time.now - elapsed).utc.iso8601,
				:encoders => @encoder_configs,
				:mime => "audio/webm",
				:codec => @encoder_configs.map { | c | c.codec2 }.uniq
			}
			script = File.read(File.expand_path('./manifest/audio.xml.erb', File.dirname(__FILE__)))
			erb(script, variables)

		end
		
		def on_new_chunk event, latest_chunk, time, caller
			update! latest_chunk
		end

		def erb(template, vars)
			ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
		end

	end
end