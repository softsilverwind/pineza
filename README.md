# Pineza

## Overview

Pineza is a simple library for visualizing points and lines on a map. It is
largely inspired by the [leaflet](https://rstudio.github.io/leaflet/) library
of the [R programming language](https://www.r-project.org/).

## Usage

This library is under development so expect backward incompatible changes to
the API.

First, clone the repository and install the dependencies with bundle:

```
$ bundle --path vendor/bundle
or
$ bundle --path ~/.bundle
```

An example in the (hopefully) current iteration is shown here:

```ruby
#!/usr/bin/env ruby

require 'pineza'

Pineza::Worker.init do |worker|
	datasets = []
	points = []

	STDIN.each_line do |line|
		line.strip!
		if !line.empty?
			point = line.split(',').map(&:to_f)
			points << [*point, point.inspect]
		else
			lines = points.each_cons(2).map { |tup| [*tup, 'green'] }
			datasets << [points, lines]
			points = []
		end
	end

	i = 0
	worker.points = datasets[i][0]
	worker.lines = datasets[i][1]

	worker.on_keypress('pn') do |c|
		if c == 'n'
			i += 1
		elsif c == 'p'
			i -= 1
		end

		i %= datasets.length

		p i

		worker.points = datasets[i][0]
		worker.lines = datasets[i][1]
	end

	worker.on_click do |lat, lon|
		p [lat, lon]
	end
end
```

Save this on the root folder of the project and run it with the following
input:
```
$ bundle exec ruby myscript.rb
37.966000,23.728500
37.967500,23.728000
37.968000,23.729500
37.969000,23.727500
37.970000,23.728000

37.966000,23.729500
37.967500,23.729000
37.968000,23.730500
37.969000,23.728500
37.970000,23.729000

37.967000,23.728500
37.968500,23.728000
37.969000,23.729500
37.970000,23.727500
37.971000,23.728000

37.967000,23.729500
37.968500,23.729000
37.969000,23.730500
37.970000,23.728500
37.971000,23.729000
```

After pressing the last <enter>, insert the EOF character with ctrl+D on unix
systems or with ctrl+Z<enter> on Windows systems.

Navigate your browser to localhost:1234 and use the 'n' and 'p' keys to navigate
between the different datasets.
