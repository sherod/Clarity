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

  def filtered_puts(mode, string)
   
  if (mode == @currentMode || @currentMode == :ALL)
      puts string
  end
end

    if (ARGV.length < 1 or ARGV.length > 3)
        puts "Usage: ruby clarity.rb [MODE] [filename]"
        exit(1)
    end

    if (ARGV.length == 1)
      @currentMode = :ALL
      filename = ARGV[0]
    else
      @currentMode = ARGV[0].intern
      filename = ARGV[1]  
    end

  
    file = File.new(filename, "r")
    indent = Array.new()
    soqlLineFlush = false
    soqlBuffer = ""
    currentMethodName = ""

    while (line = file.gets)
            pos = 0
            methodLine = false
            soqlLine = false
             line.split("|").each {|e|
                e.strip!
                if (pos == 1) 
                  
                  if (e == "METHOD_ENTRY" or e== "CODE_UNIT_STARTED")
                    indent.push(" ")
                    methodLine = true
                  elsif (e == "METHOD_EXIT")
                     indent.pop
                  elsif (e == "SOQL_EXECUTE_BEGIN")
                    soqlLine = true
                   elsif (e == "SOQL_EXECUTE_END")
                    soqlLineFlush = true
                  end

                end

                if (pos == 3)
                      if (soqlLineFlush == true)    
                            filtered_puts :SOQL, indent.join + "      " + currentMethodName + " runs [" + soqlBuffer + "] and finds "  + e.split(":")[1] + " rows"
                            soqlLineFlush = false
                            soqlBuffer = ""
                      end   
                end

                if (pos == 4)
                  if (methodLine == true and not(e.include? "__sfdc_"))
                   currentMethodName = e
                   filtered_puts :METHOD, indent.join + "calls " + currentMethodName
                  elsif (soqlLine == true)
                   soqlBuffer = e;
                  end
                end



                pos = pos + 1
             }
    end
    file.close
rescue => err
    puts "Exception: #{err}"
    err
end

