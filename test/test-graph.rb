require "cairo/graph"

class GraphTest < Test::Unit::TestCase
  class BaseTest < self
    def setup
      @graph = Cairo::Graph.new
    end

    def test_new
      assert_not_nil(@graph)
    end
  end
end
