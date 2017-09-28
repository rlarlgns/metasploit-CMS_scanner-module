require './version_sort'

class Version_compare
	include Version_sort
	##########################################################################################
	# Auth : Kimkihoon
	# edit_date : 2017.09.01
	# description :
	# 최신 버전 디렉토리, 구 버전 디렉토리를 인자로 받아 새롭게 추가된 파일과 수정된 파일 검사
	# 수정된 파일의 경우 경로와 수정된 데이터를 출력
	# 새롭게 생성된 데이터의 경우 경로만 출력
	# 수정된 파일 중 몇몇 확장자 (ex. php)를 별도로 제외하여 경로만 출력
	# get_version_data에 종속적임 ( 수정중... )
	##########################################################################################
	def compare_version_directory(file_name, last_ver_dir, old_ver_dir, xml_data)
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
		exception_object = Array.new

		exception_list = '**.{php,gif,png,jpg,mp3,swf,htc,js}'
		last_arr.each do |x|
			if(!old_arr.include?(x))
				new_object.push(x)
			else
				if(File.file?(x))
					#last_file = File.open(last_ver_dir + '/' + x, "r:UTF-8").read
					#old_file = File.open(old_ver_dir + '/' + x, "r:UTF-8").read

					#f1 = IO.readlines(last_ver_dir + '/' + x).map(&:chomp).join.encoding
					f1 = File.open(last_ver_dir + '/' + x, "r:UTF-8").readlines().map(&:chomp)
					#f2 = IO.readlines(old_ver_dir + '/' + x).map(&:chomp).join.encoding
					f2 = File.open(old_ver_dir + '/' + x, "r:UTF-8").readlines().map(&:chomp)

					if(f1 != f2)
						if(File.fnmatch(exception_list, x, File::FNM_EXTGLOB) == true)
							exception_object.push(x)
						else
							xml_data.push("<url url_ID=\"/" + x + "\">\n")
							xml_data.push("<data>" + "\n")
							data = (f1-f2).join("\n")
							xml_data.push(data)
							xml_data.push("</data>" + "\n")
							xml_data.push("</url>\n")
						end
					end

				end
			end

		end

		new_object.each do |url|
			xml_data.push("<url url_ID=\"/" + url + "\">" + "</url>\n")
		end
	end

	############################################################
	# Auth : Kimkihoon
	# edit_date : 2017.09.01
	# description :
	# 해당 CMS 폴더에 있는 버전들을 검사하여 데이터 출력
	# ex) version 소스코드 디렉토리 구조
	# 		그누보드
	# 		=> 그누보드4, 그누보드 5
	# 		=> => 각 version 소스코드
	# XML 형식 파일 출력 cms_name + _data
	# 실행파일과 cms_name 폴더가 같은 디렉토리에 위치해야 함
	#############################################################
	def get_data(cms_name)
		cms_dir = Dir.pwd + "/" + cms_name
		Dir.chdir(cms_dir)
		file_name = cms_dir + "_data.xml"
		puts file_name

		xml_data = Array.new
		xml_data.push("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\n")
		xml_data.push("<CMS_Detection CMS_ID=\"" + cms_name + "\">" + "\n")

		cms_type_arr = Dir.glob("*")
		type_base = Dir.pwd

		cms_type_arr.each do |cms_type|
			puts cms_type
			cms_type_dir = type_base + "/" + cms_type
			Dir.chdir(cms_type_dir)

			xml_data.push("<CMS_type type_ID=\"" + cms_type + "\">" + "\n")
			version_arr = Dir.glob("*")
			version_arr = version_sort(version_arr)
			version_base = Dir.pwd

			for i in 1..version_arr.size()-1
				puts "================================================="
				puts "   WORK #{i}  " + version_arr[i] + " " + version_arr[i-1]

				version = version_arr[i].gsub(/[a-z_]/,'')
				xml_data.push("<version value=\"" + version + "\">" + "\n")

				compare_version_directory(file_name, version_arr[i], version_arr[i-1], xml_data)

				xml_data.push("</version>" + "\n")
				Dir.chdir(version_base)
				puts "================================================="
			end
			xml_data.push("</CMS_type>" + "\n")
			Dir.chdir(type_base)
		end

		xml_data.push("</CMS_Detection>" + "\n")
		make_xml_file(file_name, xml_data)

		return 0
	end

	def make_xml_file(file_name, file_data)
				File.new(file_name, "w")
				file_data.each do |data|
					File.open(file_name, "a") { |f| f.write(data) }
				end
	end

	def initialize(cms_name)
		return get_data(cms_name)
	end
end
