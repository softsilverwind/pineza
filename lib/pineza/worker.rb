require 'erb'

require 'pineza/structs'
require 'pineza/server'

require_relative 'modules'

class Pineza::Worker
	attr_accessor :index, :datasets
	# Datadir = Gem.datadir('pineza') || 'data/' # buggy
	Datadir = File.join(Gem.loaded_specs['pineza'].full_gem_path, 'data') || 'data'

	def initialize
		@callbacks = {}
		@datasets = []
		@index = 0
	end

	def on_keypress(chars = [], &callback)
		if chars == []
			@callbacks['default'] = callback
		else
			chars = chars.split('') if chars.class == String
			chars.each do |char|
				@callbacks[char] = callback
			end
		end
	end

	def on_click(&callback)
		@callbacks['click'] = callback
	end

	def keypress_callback(char)
		@callbacks[char] || @callbacks['default'] || lambda { |char| }
	end

	def click_callback()
		@callbacks['click'] || lambda { |x, y| }
	end

	def current_dataset
		@datasets[index]
	end

	def next_dataset
		@index += 1
		@index %= @datasets.size
	end

	def previous_dataset
		@index -= 1
		@index = @datasets.size - 1 if index < 0
	end

	class << self
		def init(&block)
			w = new
			block.call(w)
			server = WEBrick::HTTPServer.new(:Port => 1234)
			server.mount "/", Pineza::Servlet, w

			trap("INT") { server.shutdown }

			server.start
		end

		private :new
	end
end
