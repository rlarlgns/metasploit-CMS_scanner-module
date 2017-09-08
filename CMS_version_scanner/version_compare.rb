module Version_compare
	#########################################
	# Auth : Kimkihoon 
	# edit_date : 2017.09.01
	# description :
	# 최신 버전 디렉토리, 구 버전 디렉토리를 인자로 받아 
	# 새롭게 추가된 파일과 수정된 파일을 출력
	# file_open으로 get_version_data에 종속적임 ( 수정중... )
	#########################################
	def Version_compare.compare_version_directory(file_name, last_ver_dir, old_ver_dir)
		base = Dir.pwd
		last_ver_dir = base + "/" + last_ver_dir
		old_ver_dir = base + "/" + old_ver_dir
		last_arr = Array.new
		old_arr = Array.new

		Dir.chdir(last_ver_dir)
		@allfile = File.join("**", "*")
		last_arr = Dir.glob(@allfile)

		Dir.chdir(old_ver_dir)
		@allfile = File.join("**", "*")
		old_arr = Dir.glob(@allfile)

		new_object = Array.new
		edit_object = Array.new
		
		last_arr.each do |x|
			if(!old_arr.include?(x)) 
				new_object.push(x)
			else
				if(File.file?(x))
					#last_file = File.open(last_ver_dir + '/' + x, "r:UTF-8").read
					#old_file = File.open(old_ver_dir + '/' + x, "r:UTF-8").read
					f1 = IO.readlines(last_ver_dir + '/' + x).map(&:chomp)
					f2 = IO.readlines(old_ver_dir + '/' + x).map(&:chomp)

					if(f1 != f2)
						File.open(file_name,"a"){ |f| f.write("\t\t\t" + "<url url_ID=\"" + x + "\">\n") }
						File.open(file_name,"a"){ |f| f.write("\t\t\t\t" + "<data>" + "\n") }
						File.open(file_name,"a"){ |f| f.write((f1-f2).join("\n")) }
						File.open(file_name,"a"){ |f| f.write("\n\t\t\t\t" +"</data>" + "\n") }
						File.open(file_name,"a"){ |f| f.write("\t\t\t" + "</url>\n") }
					end
				end
			end
		end

		new_object.each do |i|
			File.open(file_name,"a"){ |f| f.write("\t\t\t" + "<url url_ID=\"" + i + "\">") }
			File.open(file_name,"a"){ |f| f.write("</url>\n") }
		end
	end

	#########################################
	# Auth : Kimkihoon 
	# edit_date : 2017.09.01
	# description :
	# 해당 CMS 폴더에 있는 버전들을 검사하여 데이터 출력
	# XML 형식 파일 출력 cms_name + _data
	# 실행파일과 cms_name 폴더가 같은 디렉토리에 위치해야 함
	# file_open을 많이 써서 좋지않은 코드 ( 수정중... )
	#########################################
	def Version_compare.get_data(cms_name)
		cms_dir = Dir.pwd + "/" + cms_name
		Dir.chdir(cms_dir)
		file_name = cms_dir + "_data.xml"
		puts file_name

		File.new(file_name, "w")
		File.open(file_name,"a"){ |f| f.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\n") }
		File.open(file_name,"a"){ |f| f.write("<scanning>" + "\n") }

		version_arr = Dir.glob("*")
		puts version_arr
		base = Dir.pwd
		File.open(file_name,"a"){ |f| f.write("\t<CMS_type type_ID=\"" + cms_name + "\">" + "\n") }

		for i in 1..version_arr.size()-1
			puts "================================================="
			puts "   WORK #{i}  " + version_arr[i] + " " + version_arr[i-1]
			version = version_arr[i].gsub(/[a-z]/,'')
			File.open(file_name,"a"){ |f| f.write("\t\t<version version_ID=\"" + version + "\">" + "\n") }

			compare_version_directory(file_name, version_arr[i], version_arr[i-1])

			File.open(file_name,"a"){ |f| f.write("\t\t</version>" + "\n") }
			Dir.chdir(base)
			puts "================================================="
		end

		File.open(file_name,"a"){ |f| f.write("\t</CMS_type>" + "\n") }
		File.open(file_name,"a"){ |f| f.write("</scanning>" + "\n") }
	end
end

