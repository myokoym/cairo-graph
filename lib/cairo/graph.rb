require "cairo"

module Cairo
  class Context
    def show_graph(graph)
      graph.draw(self)
    end
  end

  class Graph
    VERSION = "0.0.2"

    LINE_COLORS = [
      Cairo::Color.parse("#CCCCE6"),
      Cairo::Color.parse("#319DE9"),
      Cairo::Color.parse("#F14040"),
      Cairo::Color.parse("#F9B351"),
      Cairo::Color.parse("#83BE41"),
      Cairo::Color.parse("#E2629C"),
      Cairo::Color::RGB.new(rand, rand, rand),
      Cairo::Color::RGB.new(rand, rand, rand),
      Cairo::Color::RGB.new(rand, rand, rand),
      Cairo::Color::RGB.new(rand, rand, rand),
    ]

    attr_reader :width
    attr_reader :height

    attr_accessor :margin_top
    attr_accessor :margin_bottom
    attr_accessor :margin_left
    attr_accessor :margin_right

    attr_accessor :line_width
    attr_accessor :point_radius

    attr_accessor :background_top_color
    attr_accessor :background_bottom_color
    attr_accessor :text_color
    attr_accessor :grid_color

    attr_accessor :title
    attr_accessor :columns
    attr_accessor :unit_name
    attr_accessor :grid_max
    attr_accessor :grid_step

    def initialize(options={})
      # TODO: validate options

      @width  = options[:width]  || 640
      @height = options[:height] || 480

      @margin_top    = @height * 0.3
      @margin_bottom = @height * 0.2
      @margin_left   = @width * 0.1 + @height * 0.05
      @margin_right  = @width * 0.15 + @height * 0.1

      @line_width   = @height * 0.01
      @point_radius = @height * 0.02

      @background_top_color = :black
      @background_bottom_color = Cairo::Color.parse("#1A1629")
      @text_color = :white
      @grid_color = :white

      @title = ""
      @columns = []
      @unit_name = nil
      @grid_max = nil
      @grid_step = nil

      @rows = []
      @names = []
      @colors = []
    end

    def add(row, name=nil, color=nil)
      @rows << row
      @names << name
      @colors << color
    end

    def draw(context)
      draw_background(context)
      draw_title(context)
      draw_grid(context)
      draw_unit_name(context)
      draw_rows(context)
      draw_names(context)
      draw_columns(context)
    end

    def draw_background(context)
      context.fill do
        context.set_source(background_pattern)
        context.rectangle(0, 0, @width, @height)
      end
    end

    def draw_title(context)
      context.font_size = @height * 0.1
      extents = context.text_extents(@title)
      x = (@width / 2) - (extents.width / 2 + extents.x_bearing)
      y = @height * 0.13
      context.move_to(x, y)
      context.set_source_color(@text_color)
      context.show_text(@title)
    end

    def draw_grid(context)
      context.set_source_color(@grid_color)
      context.set_line_width(@line_width * 0.2)
      x1 = @margin_left * 0.9
      x2 = @width - @margin_right * 0.9
      0.step(grid_max, grid_step) do |value|
        scale = value.to_f / grid_max
        y = @height - (@margin_bottom + (graph_area_height * scale))
        draw_grid_line(context, value, x1, x2, y)
        draw_grid_value(context, value, y)
      end
    end

    def draw_unit_name(context)
      return unless @unit_name
      font_size = @height * 0.05
      context.font_size = font_size
      extents = context.text_extents(@unit_name)
      x = @margin_left - (extents.width + extents.x_bearing)
      y = @margin_top * 0.7
      context.move_to(x, y)
      context.show_text(@unit_name)
    end

    def draw_rows(context)
      context.set_line_width(@line_width)
      @rows.size.times do |index|
        draw_row(context, index)
      end
    end

    def draw_names(context)
      font_size = @height * 0.05
      context.font_size = font_size
      x1 = @width - (@margin_right * 0.85)
      x2 = @width - (@margin_right * 0.1)
      @names.each_with_index do |name, i|
        context.set_source_color(@colors[i] || LINE_COLORS[i])
        text = (@names[i] || (i + 1)).to_s
        y = (@margin_top * 0.7) + (font_size * i * 1.8)
        context.stroke do
          context.move_to(x1, y + font_size * 0.4)
          context.line_to(x2, y + font_size * 0.4)
        end
        context.move_to(x1, y)
        context.show_text(text)
      end
    end

    def draw_columns(context)
      context.set_source_color(@text_color)
      context.font_size = @height * 0.04
      columns.each_with_index do |column, i|
        extents = context.text_extents(column)
        x = interval_x * i + @margin_left - (extents.width / 2 + extents.x_bearing)
        if column.length > (@width / @height * 4) && i % 2 == 0
          y = @height - (@margin_bottom * 0.4)
        else
          y = @height - (@margin_bottom * 0.6)
        end
        context.move_to(x, y)
        context.show_text(column)
      end
    end

    private
    def draw_grid_line(context, value, x1, x2, y)
      context.stroke do
        context.move_to(x1, y)
        context.line_to(x2, y)
      end
    end

    def draw_grid_value(context, value, line_y)
      context.font_size = @height * 0.05
      text = value.to_s
      extents = context.text_extents(text)
      x = @margin_left * 0.8 - (extents.width + extents.x_bearing)
      y = line_y - (extents.height / 2 + extents.y_bearing)
      context.move_to(x, y)
      context.set_source_color(@text_color)
      context.show_text(text)
    end

    def draw_row(context, index)
      row = @rows[index]
      context.set_source_color(@colors[index] || LINE_COLORS[index])
      points = []
      row.each_with_index do |value, i|
        x = interval_x * i + @margin_left
        y = @height - (value * interval_y + @margin_bottom)
        points << [x, y]
      end

      context.stroke do
        points.each_with_index do |point, i|
          x, y = *point
          if i == 0
            context.move_to(x, y)
          else
            context.line_to(x, y)
          end
        end
      end

      points.each do |point|
        x, y = *point
        context.fill do
          context.circle(x, y, @point_radius)
        end
      end
    end

    def grid_max
      return @grid_max if @grid_max
      base = (data_max - 1).floor.to_s
      case base[0].to_i
      when 0
        1.0
      when 1
        if base.length > 1 && base[1].to_i < 5
          10 ** base.length / 8
        else
          10 ** base.length / 5
        end
      when 2
        10 ** base.length / 4
      when 3..5
        10 ** base.length / 2
      else
        10 ** base.length
      end
    end

    def grid_step
      return @grid_step if @grid_step
      (grid_max.to_f / 5).round
    end

    def interval_x
      case data_size
      when 1
        0
      else
        graph_area_width.to_f / (data_size - 1)
      end
    end

    def interval_y
      graph_area_height.to_f / grid_max
    end

    def data_max
      @rows.collect {|row| row.max }.max
    end

    def data_size
      @rows.max {|row| row.size }.size
    end

    def graph_area_width
      @width - @margin_left - @margin_right
    end

    def graph_area_height
      @height - @margin_top - @margin_bottom
    end

    def background_pattern
      pattern = Cairo::LinearPattern.new(@width / 2, 0,
                                         @width / 2, @height)
      pattern.add_color_stop(0.0, @background_top_color)
      pattern.add_color_stop(1.0, @background_bottom_color)
      pattern
    end
  end
end
