require 'mkmf'

RUBY_VERSION =~ /(\d+.\d+)/
extension_name = "perlin/#{$1}/perlin"

dir_config(extension_name)

# 1.9 compatibility
$CFLAGS += ' -DRUBY_19' if RUBY_VERSION =~ /^1.9/

# let's use c99
$CFLAGS += " -std=gnu99"

# Avoid warnings since we are using C99, not C90!
$warnflags.gsub!('-Wdeclaration-after-statement', '') if $warnflags

create_makefile(extension_name)