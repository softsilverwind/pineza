Gem::Specification.new do |spec|
	spec.name          = 'pineza'
	spec.version       = '0.1.0'
	spec.authors       = ['Nikolaos Vathis']
	spec.email         = ['nvathis@softlab.ntua.gr']

	spec.summary       = 'Library to visualize POIs and routes'
	spec.description   = 'This library visualizes POIs and routes using leaflet'
	spec.license       = 'GPL-3.0'

	spec.require_paths = ['lib']
	spec.files         = Dir['lib/**/*', 'data/**/*']
end
