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
        abort "Usage: ruby clarity.rb [MODE] [filename]"
    end

    if (ARGV.length == 1)
      @currentMode = :ALL
      filename = ARGV[0]
    else
      @currentMode = ARGV[0].intern
      filename = ARGV[1]  
    end
 


    indent = Array.new()
    flushType = nil
    soqlBuffer = ""
    currentMethodName = ""
    currentRuleName = ""
    currentFilter = ""
    workflowCircumstance = ""
    INDENT = " "
    SEPERATOR = "|"
  
    file = File.new(filename, "r")
   
    while (line = file.gets)
            columnNumber = 0
            lineType = :unknown

             line.split(SEPERATOR).each {|columnToken |
                columnToken.strip!
                if (columnNumber == 1) 
                  
                  if (columnToken == "METHOD_ENTRY" or columnToken== "CODE_UNIT_STARTED")
                    indent.push(INDENT)
                    lineType = :methodLine
                  elsif (columnToken == "METHOD_EXIT")
                     indent.pop
                  elsif (columnToken == "USER_DEBUG")
				     lineType = :debugLine
				  elsif (columnToken == "SOQL_EXECUTE_BEGIN")
                    lineType = :soqlLine
                  elsif (columnToken == "SOQL_EXECUTE_END")
                    flushType = :soqlLine
                  elsif (columnToken == "WF_CRITERIA_BEGIN")
                    lineType = :workflowLine
                  elsif (columnToken == "WF_CRITERIA_END")
                    lineType = :workflowLine
                    flushType = :workflowLine
                  elsif (columnToken == "WF_RULE_EVAL_BEGIN")
                    lineType = :workflowType
                  elsif (columnToken == "WF_RULE_FILTER")
                    lineType = :workflowFilter
                  end

                end

                if (columnNumber == 2)

                  if (lineType == :workflowType)
                     filtered_puts :WORKFLOW, "Running '" + columnToken + "' rules" 
                  elsif (lineType == :workflowLine and flushType == :workflowLine)
                      if (columnToken == 'false')
                          d = 'did not'
                      else
                        d = 'DID'
                      end
                      filtered_puts :WORKFLOW, " Rule '" + currentRuleName + "' " + d  + " fire" 
                      filtered_puts :WORKFLOW, "   Filter starts with '" + currentFilter + "...' and rule set to run on '" + workflowCircumstance + "'"
                      flushType = nil
                  elsif(lineType == :workflowFilter)
                      currentFilter = columnToken
                  end

                end

                if (columnNumber == 3)
                    if (lineType == :workflowLine)
                      currentRuleName = columnToken
                    end             

                    if (flushType == :soqlLine)    
                          filtered_puts :SOQL, indent.join + "      " + currentMethodName + " runs [" + soqlBuffer + "] and finds "  + columnToken.split(":")[1] + " rows"
                          flushType = nil
                          soqlBuffer = ""
                    end   
                end

                if (columnNumber == 4)
                  if (lineType == :methodLine  and not(columnToken.include? "__sfdc_"))
                   currentMethodName = columnToken
                   filtered_puts :METHOD, indent.join + "calls " + currentMethodName
                  elsif (lineType == :soqlLine)
                   soqlBuffer = columnToken;
				  elsif (lineType == :debugLine)
				   filtered_puts :METHOD, indent.join + "debug " + columnToken
                  end
                end

                if (columnNumber == 5)
                  if (lineType == :workflowLine)
                    workflowCircumstance = columnToken
                  end
                end

                columnNumber += 1
             }
    end

    file.close

end

