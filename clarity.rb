#!/usr/bin/ruby
# Copyright (c) 2012 Steven Herod, http://github.com/sherod/Clarity

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Working with logs as at API Version 23/24 - April 2012.

begin

    if (ARGV.length != 1)
        puts "Usage: ruby clarity.rb [filename]"
        exit(1)
    end

    file = File.new(ARGV[0], "r")
    indent = Array.new()
    while (line = file.gets)
            pos = 0
            methodLine = false
             line.split("|").each {|e|

                if (pos == 1 and (e == "METHOD_ENTRY" or e== "CODE_UNIT_STARTED"))
                  indent.push("    ")
                  methodLine = true
                elsif (pos == 1 and (e == "METHOD_EXIT"))
                   indent.pop
                end

                if (pos == 4 and methodLine == true and not(e.include? "__sfdc_"))
                   puts indent.join + "calls " + e
                end

                pos = pos + 1
             }
    end
    file.close
rescue => err
    puts "Exception: #{err}"
    err
end
