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

class StrUtil
	def self.ensureUtf8(str, replaceChr="_")
		str = str.to_s
		str.encode!("UTF-8", :invalid=>:replace, :undef=>:replace, :replace=>replaceChr) if !str.valid_encoding?
		return str
	end

	def self.robustIndex(key, strArray, i)
		if i < strArray.length then
			str = strArray[i].to_s
			index = str.index(key)
			return index if index

			keys = key.split
			return nil if keys.length == 1

			found = true
			index = nil
			j = 0
			keys.each do |aKey|
				index2 = str.index(aKey)
				if index2 then
					# found
					if j == 0 then
						index = index2
					end
				else
					break if j == 0
					# not found in current str
					if (i+1) < strArray.length then
						# try with next string in the array
						i = i + 1
						str = str + strArray[i].to_s
						index2 = str.index(aKey)
						if nil == index2 then
							found = false
							break
						else
							if j == 0 then
								index = index2
							end
						end
					else
						found = false
						break
					end
				end
				break if !found
				j = j + 1
			end
			if found && index then
				return index
			end
		end

		return nil
	end
end
