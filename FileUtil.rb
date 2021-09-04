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

require "./StrUtil"

class FileUtil
	def self.ensureDirectory(path)
		paths = path.split("/")

		path = ""
		paths.each do |aPath|
			path += "/"+aPath
			Dir.mkdir(path) if !Dir.exist?(path)
		end
	end

	def self.removeDirectoryIfNoFile(path)
		found = false
		Dir.foreach( path ) do |aPath|
			next if aPath == '.' or aPath == '..'
			found = true
			break
		end
		FileUtils.rm_rf(path) if !found
	end

	def self.cleanupDirectory(path, recursive=false, force=false)
		if recursive && force then
			FileUtils.rm_rf(path)
		elsif recursive then
			FileUtils.rm_r(path)
		elsif force then
			FileUtils.rm_f(path)
		else
			FileUtils.rmdir(path)
		end

		ensureDirectory(path)
	end

	def self.iteratePath(path, matchKey, pathes, recursive, dirOnly)
		Dir.foreach( path ) do |aPath|
			next if aPath == '.' or aPath == '..'

			fullPath = path.sub(/\/+$/,"") + "/" + aPath
			if FileTest.directory?(fullPath) then
				if dirOnly then
					if matchKey==nil || ( aPath.match(matchKey)!=nil ) then 
						pathes.push( fullPath )
					end
				end
				if recursive then
					iteratePath( fullPath, matchKey, pathes, recursive, dirOnly )
				end
			else
				if !dirOnly then
					if matchKey==nil || ( aPath.match(matchKey)!=nil ) then 
						pathes.push( fullPath )
					end
				end
			end
		end
	end

	def self.getFilenameFromPath(path)
		pos = path.rindex("/")
		path = path.slice(pos, path.length-pos) if pos
		return path
	end

	# get regexp matched file list
	def self.getRegExpFilteredFiles(basePath, fileFilter)
		result=[]
		iteratePath(basePath, fileFilter, result, true, false)

		return result
	end

	def self.writeFile(path, body)
		if path then
			fileWriter = File.open(path, "w")
			if fileWriter then
				if body.kind_of?(Array) then
					body.each do |aLine|
						fileWriter.puts aLine
					end
				else
					fileWriter.puts body
				end
				fileWriter.close
			end
		end
	end

	def self.readFile(path)
		result = nil

		if path && FileTest.exist?(path) then
			fileReader = File.open(path)
			if fileReader then
				result = StrUtil.ensureUtf8(fileReader.read)
				fileReader.close
			end
		end

		return result
	end

	def self.readFileAsArray(path)
		result = []

		if path && FileTest.exist?(path) then
			fileReader = File.open(path)
			if fileReader then
				while !fileReader.eof
					result << StrUtil.ensureUtf8(fileReader.readline).strip
				end
				fileReader.close
			end
		end

		return result
	end

	def self.appendLineToFile(path, line)
		open(path, "a") do |f|
			f.puts line
		end
	end
end
