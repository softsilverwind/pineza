require 'logger'

require_relative 'modules'
require_relative 'server'
require_relative 'popupform'

class Pineza::Worker
	attr_accessor :points, :lines, :metadata
	# Datadir = Gem.datadir('pineza') || 'data/' # buggy
	Datadir = File.join(Gem.loaded_specs['pineza'].full_gem_path, 'data') || 'data'

	def initialize
		@callbacks = {}
		@points = []
		@lines = []
	end

	def on_keypress(chars = '', &callback)
		if chars == ''
			@callbacks['default'] = callback
		else
			chars.each_char do |char|
				@callbacks[char] = callback
			end
		end
	end

	def on_click(&callback)
		@callbacks['click'] = callback
	end

	def on_marker_click(&callback)
		@callbacks['marker_click'] = callback
	end

	def on_edit(&callback)
		@callbacks['edit'] = callback
	end

	def keypress_callback(char)
		@callbacks[char] || @callbacks['default'] || lambda { |char| }
	end

	def click_callback
		@callbacks['click'] || lambda { |x, y| }
	end

	def marker_click_callback
		@callbacks['marker_click'] || lambda { |id| }
	end

	def edit_callback
		@callbacks['edit'] || lambda { |data| }
	end

	def metadata
		if @points.length > 0 && @points[0][2].class == Hash
			@points[0][2].keys
		end
	end

	def dataset
		{
			points: @points.map { |p| { lat: p[0], lon: p[1], info: p[2].class == Hash ? Pineza::PopupForm::generate(p[2]) : p[2] } },
			lines:
				@lines.map { |p|
					{
						start: { lat: p[0][0], lon: p[0][1] },
						finish: { lat: p[1][0], lon: p[1][1] },
						color: p[2]
					}
				}
		}
	end

	class << self
		def init(&block)
			w = new
			block.call(w)
			#server = WEBrick::HTTPServer.new(Port: 1234, AccessLog: [], Logger: Logger.new('/dev/null'))
			server = WEBrick::HTTPServer.new(Port: 1234)
			server.mount "/", Pineza::Servlet, w

			trap("INT") { server.shutdown }

			server.start
		end

		private :new
	end
end
