############################################################
# Auth : Kimkihoon
# edit_date : 2017.09.01
# description :
# Nexpose Module 제작용 CMS scanner
#############################################################
require './version_sort'
require 'htmlentities'

class Version_compare_Nexpose
	include Version_sort

	############################################################
	# Auth : Kimkihoon
	# edit_date : 2017.09.29
	# description :
	# 해당 CMS 폴더에 있는 버전들을 검사하여 데이터 출력
	# ex) version 소스코드 디렉토리 구조
	# 		그누보드
	# 		=> 그누보드4, 그누보드 5
	# 		=> => 각 version 소스코드
	# 실행파일과 cms_name 폴더가 같은 디렉토리에 위치해야 함
	# return :
	# 버전 별로 각각 두 파일 생성
	# XML 형식 파일 출력 cms_name + _check.xml
	# VCK 형식 파일 출력 cms_name + _check.vck
	#############################################################
	def get_data(cms_name)
		file_dir = Dir.pwd
		cms_dir = Dir.pwd + "/" + cms_name
		Dir.chdir(cms_dir)

		cms_type_arr = Dir.glob("*")
		type_base = Dir.pwd

		cms_type_arr.each do |cms_type|
			puts cms_type
			cms_type_dir = type_base + "/" + cms_type
			Dir.chdir(cms_type_dir)

			# version_list
			version_arr = Dir.glob("*")
			version_arr = version_sort(version_arr)
			version_base = Dir.pwd

			for i in 1..version_arr.size()-1
				puts "================================================="
				puts "   WORK #{i}  " + version_arr[i] + " " + version_arr[i-1]

				file_data = compare_version_directory(version_arr[i], version_arr[i-1])

				make_vck_file(file_dir, version_arr[i], file_data)
				make_xml_file(file_dir, version_arr[i], cms_name)

				Dir.chdir(version_base)
				puts "================================================="
			end

		end
		return 0
	end

	##########################################################################################
	# Auth : Kimkihoon
	# edit_date : 2017.09.29
	# func : compare_version_directory
	# input
	# => last_ver_dir : 선행 버전 디렉토리
	# => old_ver_dir : 구 버전 디렉토리
	# output
	# => vck file data array
	# description :
	# 최신 버전 디렉토리, 구 버전 디렉토리를 인자로 받아 새롭게 추가된 파일과 수정된 파일 검사
	# 수정된 파일의 경우 경로와 수정된 데이터를 출력
	# 새롭게 생성된 데이터의 경우 경로만 출력
	# 수정된 파일 중 몇몇 확장자 (ex. php)를 별도로 제외하여 경로만 출력
	##########################################################################################
	def compare_version_directory(last_ver_dir, old_ver_dir)
		
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

		vck_data = Array.new
		new_object = Array.new
		edit_object = Array.new
		same_object = Array.new

		exception_list = '**.{php,gif,png,jpg,mp3,swf,htc}'

		last_arr.each do |x|
			# 구 버전에 새로운 버전의 파일이 포함되어 있는가
			if(!old_arr.include?(x))
				# 새롭게 생성된 파일 저장
				new_object.push(x)
			else
				# 구 버전과 동일한 파일
				same_object.push(x)
			end
		end
		
		# 파일 차이 비교
		file_compare(same_object, vck_data)

		# 새롭게 생성된 파일 처리
		new_object.each do |url|
			if(url.casecmp('/xe') == 1)
				url = url[2, url.length()-1]
			end
			if(url.length != 0)
				vck_data.push("<HTTPCheck>" + "\n")
				#Request
				vck_data.push("<HTTPRequest method=\"GET\">" + "\n")
				vck_data.push("<URI>" + url + "</URI>\n")
				vck_data.push("</HTTPRequest>" + "\n")
				#Response
				vck_data.push("<HTTPResponse code=\"403\">" + " </HTTPResponse>" + "\n")
				vck_data.push("</HTTPCheck>" + "\n\n")
			end
		end
		return vck_data
	end

	############################################################
	# Auth : Kimkihoon
	# edit_date : 2017.10.10
	# func : file_compare
	# input 
	# => same_object : 비교한 버전의 같은 파일 리스트
	# => vck_data : array
	# description :
	# 두 파일을 비교하여 차이가 발견될 경우 해당 파일을 vck_data에 추가
	# Nexpose template form 예외 처리
	# => . $ ^ { } [ ] ( | ) * + ? \ 문자에 대하여 정규식 처리
	# => data에 tag가 존재할 경우 인식 불가로 entity 변환 처리
	#############################################################
	def file_compare(same_object, vck_data)
		same_object.each do |x|
			if(File.file?(x))
				f1 = File.open(last_ver_dir + '/' + x, "r:UTF-8").readlines().map(&:chomp)
				f2 = File.open(old_ver_dir + '/' + x, "r:UTF-8").readlines().map(&:chomp)

				if(f1 != f2)
					if(File.fnmatch(exception_list, x, File::FNM_EXTGLOB) == false)
						vck_data.push("<HTTPCheck>" + "\n")
						#Request
						vck_data.push("<HTTPRequest method=\"GET\">" + "\n")
						uri = ''
						if(x.casecmp('/xe') == 1)
							uri = x[2, x.length()-1]
						end
						vck_data.push("<URI>" + uri + "</URI>\n")
						vck_data.push("</HTTPRequest>" + "\n")
						#Response
						vck_data.push("<HTTPResponse code=\"200\">" + "\n")
						vck_data.push("<and>" + "\n")

						# Nexpose 호환 데이터 인코딩
						encoding_data(f1, vck_data)

						vck_data.push("</and>" + "\n")
						vck_data.push("</HTTPResponse>" + "\n")

						vck_data.push("</HTTPCheck>" + "\n\n")
					end
				end

			end
		end
	end

	############################################################
	# Auth : Kimkihoon
	# edit_date : 2017.10.10
	# func : encoding_data
	# input 
	# => f1 : 파일 데이터
	# => regex_data : array
	# description :
	# 입력받은 파일은 인코딩 하여 배열에 저장
	#############################################################
	def encoding_data(f1, regex_data)

		data = (f1).join("\n").encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => "_")
		# 정규표현식 내부 특수문자 처리
		data = data.gsub(/([\.\$\^\{\}\[\]\(\|\)\*\+\?\\])/, '.' => '\.', '$' => '\$', '^' => '\^',
		 '{' => '\{', '}' => '\}', '[' => '\[', ']' => '\]', '(' => '\(', ')' => '\)', '|' => '\|',
		  '*' => '\*', '+' => '\+', '?' => '\?', '\\' => '\\\\')
		# html 엔티티 처리
		data = HTMLEntities.new.encode(data);
		data = data.split("\n")
		data.each do |d|
			if(d.length != 0 && d.foreign_language? == false)
				regex_data.push("<regex>" + d + "</regex>\n")
			end
		end
	end

	############################################################
	# Auth : Kimkihoon
	# edit_date : 2017.10.10
	# func : make_xml_file
	# input
	# => file_location : 파일 생성 디렉토리
	# => cms_version   : cms 배포판 버전 명
	# => cms_name      : cms 이름
	# description :
	# Nexpose Module 형식은 xml 파일을 만든다.
	#############################################################
	def make_xml_file(file_locate, cms_version, cms_name)
		cms_version = cms_version.gsub(/([_])/, '-')
		file_name = file_locate + '/' + "cmty-" + cms_version + ".xml"

		File.new(file_name, "w")

		xml_data = Array.new
		xml_data.push("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\n")
		xml_data.push("<Vulnerability id=\"" + "cmty-" + cms_version +"\" published=\"2017-09-29\" added=\"2017-09-29\" modified=\"2017-09-29\" version=\"1.0\">" + "\n")
		xml_data.push("<name>" + "cmty-" + cms_version + "</name>"+ "\n")
		xml_data.push("<Tags>"+ "\n")
		xml_data.push("<tag>" + cms_name + "</tag>"+ "\n")
		xml_data.push("<tag>CMS_version_scan</tag>"+ "\n")
		xml_data.push("</Tags>"+ "\n")
		xml_data.push("<cvss>(AV:N/AC:L/Au:N/C:P/I:N/A:N)</cvss>"+ "\n")
		xml_data.push("<AlternateIds>\n"+ "<id name=\"URL\">" + "http://test.com</id>" +"\n</AlternateIds>"+ "\n")
		xml_data.push("<Description>" + "<p> CMS_version_scan </p>" + "</Description>\n")
		xml_data.push("<Solutions>"+ "\n")
		xml_data.push("<Solution id=\""+ "cmty-" + cms_version + "\" time=\"30m\">"+ "\n")
		xml_data.push("<summary> CMS_version_scan </summary>\n")
		xml_data.push("<workaround> <p> test </p> </workaround>\n")
		xml_data.push("</Solution>"+ "\n")
		xml_data.push("</Solutions>"+ "\n")
		xml_data.push("</Vulnerability>"+ "\n")

		xml_data.each do |data|
			File.open(file_name, "a") { |f| f.write(data) }
		end
	end

	############################################################
	# Auth : Kimkihoon
	# edit_date : 2017.10.10
	# func : make_vck_file
	# input
	# => file_location : 파일 생성 디렉토리
	# => cms_version   : cms 배포판 버전 명
	# => file_data     : 검사 데이터
	# output
	# => "cmty-" + cms_version + ".vck"
	# description :
	# Nexpose Module의 형식인 vck 파일을 생성한다.
	#############################################################
	def make_vck_file(file_locate, cms_version, file_data)
		cms_version = cms_version.gsub(/([_])/, '-')
		file_name = file_locate + '/' + "cmty-" + cms_version + ".vck"
		File.new(file_name, "w")

		vck_data = Array.new
		vck_data.push("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + "\n")
		vck_data.push("<VulnerabilityCheck id=\"" + "cmty-" + cms_version +"\" scope=\"endpoint\">" + "\n")
		vck_data.push("<NetworkService type=\"HTTP|HTTPS\"/>\n")
		vck_data.push("<and>\n")

		vck_data.each do |data|
			File.open(file_name, "a") { |f| f.write(data) }
		end

		file_data.each do |data|
			File.open(file_name, "a") { |f| f.write(data) }
		end

		vck_data_bottom = Array.new
		vck_data_bottom.push("</and>\n")
		vck_data_bottom.push("</VulnerabilityCheck>\n")

		vck_data_bottom.each do |data|
			File.open(file_name, "a") { |f| f.write(data) }
		end
	end

	# 초기화 함수
	def initialize(cms_name)
		return get_data(cms_name)
	end
end

# 예외처리용 클래스
# 영어를 제외한 언어 식별
class String
  def foreign_language?
    (chars.count < bytes.count)
  end
end