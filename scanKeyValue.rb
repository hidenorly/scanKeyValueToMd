#!/usr/bin/ruby

#  Copyright (C) 2021 hidenorly
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'optparse'
require './TaskManager'
require './FileUtil'

class ScanTask < TaskAsync
	def initialize(path, rule, resultCollector)
		@path = path
		@rule = rule
		@resultCollector = resultCollector
		super("ScanTask::#{path}")
	end

	def getMatchedValue( key, body, i )
		value = nil
		valueRequired = false

		# check key requires the value or not and get search key and keyEnd
		keyEnd = nil
		valIndex = key.rindex("@")
		if valIndex then
			keyEnd = key[valIndex+1..key.length].strip
			keyEnd = nil if keyEnd.empty?
			key = key[0..valIndex-1]
			valueRequired = true
		end

		foundRule = false
		while (i < body.length) && !foundRule
			aLine = body[i]
			keyIndex = aLine.index(key)
			if keyIndex then
				foundRule = true
				if valueRequired then
					value = aLine[ keyIndex+key.length..aLine.length ]
					if keyEnd then
						endIndex = value.rindex( keyEnd )
						if endIndex then
							# single line case
							value = value[0..endIndex-1]
						else
							# multi line case
							j = i + 1
							value2, i2 = getMatchedValue( keyEnd+"@", body, j )
							if value2 && i2 then
								while j < i2
									value = value.to_s + body[j]
									j = j + 1
								end
								value = value[0..value.rindex( keyEnd )-1]
								i = i2 - 1
							end
						end
					end
				end
			end
			i = i + 1
		end

		return value, i
	end

	def execute
		result = []
		if FileTest.exist?(@path) then
			fileBody = FileUtil.readFileAsArray(@path)

			i = 0
			@rule.each do | aRule |
				value, i = getMatchedValue( aRule, fileBody, i )
				if value then
					result.push( value )
				end
			end
		end

		@resultCollector.onResult(@path, result) if !result.empty?
		_doneTask()
	end
end

class ResultCollector
	def initialize
		@result = {}
		@_mutex = Mutex.new
	end
	def onResult( path, result )
		@_mutex.synchronize {
			@result[ path ] = result
		}
	end
	def dump
		@result.each do |aPath, result|
			print "| " + aPath.to_s + " | "
			result.each do |aValue|
				print aValue.to_s + " | "
			end
			puts ""
		end
	end
end


#---- main --------------------------
options = {
	:scanDir => ".",
	:extension => "\.c$",
	:recursive => false,
	:ruleFile => "",
	:numOfThreads => TaskManagerAsync.getNumberOfProcessor()
}

opt_parser = OptionParser.new do |opts|
	opts.banner = "Usage: "

	opts.on("-s", "--scanDir=", "Specify scan target dir") do |scanDir|
		options[:scanDir] = scanDir
	end

	opts.on("-e", "--extension=", "Specify target file extension (#{options[:extension]})") do |extension|
		options[:extension] = extension
	end

	opts.on("-r", "--ruleFile=", "Specify rule file (mandatory)") do |ruleFile|
		options[:ruleFile] = ruleFile
	end

	opts.on("", "--recursive", "Specify if you want to search recursively") do |recursive|
		options[:recursive] = recursive
	end
end.parse!

options[:scanDir] = File.expand_path(options[:scanDir])
if options[:ruleFile].empty? then
	puts "You need to specify -r rule.txt"
	exit(-1)
else
	options[:ruleFile] = File.expand_path(options[:ruleFile])
end

rules = ""
if FileTest.exist?(options[:ruleFile]) then
	rules = FileUtil.readFileAsArray(options[:ruleFile])
end

taskMan = TaskManagerAsync.new( options[:numOfThreads].to_i )

pathes = []
FileUtil.iteratePath(options[:scanDir], options[:extension], pathes, options[:recursive], false)

result = ResultCollector.new()

pathes.each do |aPath|
	taskMan.addTask( ScanTask.new( aPath, rules, result ) )
end

taskMan.executeAll()
taskMan.finalize()
result.dump()