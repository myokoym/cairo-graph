lib_dir = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require "cairo/graph"

Gem::Specification.new do |spec|
  spec.name = "cairo-graph"
  spec.version = Cairo::Graph::VERSION
  spec.authors = ["Masafumi Yokoyama"]
  spec.email = ["yokoyama@clear-code.com"]

  spec.summary = %q{Graphing library for rcairo.}
  spec.description = %q{A library that can generate graph easily, by cairo (rcairo) and Ruby.}
  spec.homepage = "https://github.com/myokoym/cairo-graph"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test|spec|features)/})}
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) {|f| File.basename(f)}
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency("cairo")

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("test-unit")
  spec.add_development_dependency("test-unit-notify")
end
