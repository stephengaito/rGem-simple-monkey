# -*- ruby -*-

# To release this ruby gem type:
#  rake release VERSION=x.y.z
# where x.y.z is the appropriate version number of this gem.

require 'rubygems'
require 'hoe'

# Hoe.plugin :compiler
# Hoe.plugin :gem_prelude_sucks
# Hoe.plugin :inline
# Hoe.plugin :minitest
# Hoe.plugin :racc
# Hoe.plugin :rubyforge

# generate the Manifest.txt file (before we invoke Hoe.spec)
manifest = FileList[
  '.gitignore', 
  'History.*', 
  'README.*', 
  'Rakefile',
  'lib/**/*.rb',
  'test/**/*.rb',
];
File.open('Manifest.txt', 'w') do | manifestFile |
  manifestFile.puts("Manifest.txt");
  manifestFile.write(manifest.to_a.join("\n"));
end

# For dependency documentation see:
#   http://guides.rubygems.org/patterns/

Hoe.spec 'simple-monkey' do
  developer('Stephen Gaito', 'stephen@perceptisys.co.uk')
  license 'MIT'
  dependency('mercenary', '~> 0.3');
  dependency('safe_yaml', '~> 1.0');
end

# vim: syntax=ruby
