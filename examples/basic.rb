#!/usr/bin/env ruby

require "cairo/graph"

rows = [
  [[253, 503,  84,  687, 859,  361, 110,  403], "Senna"],
  [[588, 766, 485, 1039, 862, 1028, 155,  235], "Groonga"],
  [[504, 192, 610,  541, 469,  192, 194, 1072], "Rroonga"],
  [[ 31, 694,  80,    3, 762,   85, 620, 1078], "Mroonga"],
  [[422, 288, 376, 1162, 153,  218, 303,  638], "Nroonga"],
  [[264, 106, 167,  586, 204,  597, 831, 1111], "Droonga"],
]

columns = [*1..8].collect do |i|
  "5/#{i}"
end

width = 960
height = 480

graph = Cairo::Graph.new(:width => width, :height => height)
graph.title = "Graph by rcairo"
graph.unit_name = "(Unit)"
graph.columns = columns
#graph.grid_max = 1200
#graph.grid_step = 200
rows.each do |row_with_name|
  row, name = *row_with_name
  graph.add(row, name)
end

Cairo::ImageSurface.new(:argb32, width, height) do |surface|
  Cairo::Context.new(surface) do |context|
    context.show_graph(graph)
  end
  surface.write_to_png("graph-by-rcairo.png")
end
