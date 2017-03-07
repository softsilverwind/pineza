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

require 'json'

require 'pineza'

Pineza::Worker.init do |worker|
    points = []

    STDIN.each_line do |line|
        line.strip!
        if line.empty?
            lines = points.each_cons(2).map do |tup|
                Pineza::Structs::Line.new *tup, 'green'
            end

            worker.datasets << {
                points: points,
                lines: lines
            }

            points = []
        else
            point = line.split(',').map(&:to_f)
            points << Pineza::Structs::Point.new(*point, point.inspect)
        end
    end

    worker.on_keypress('n') { worker.next_dataset }
    worker.on_keypress('p') { worker.previous_dataset }

    worker.on_click { |lat, lon|
        p [lat, lon]
    }
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
