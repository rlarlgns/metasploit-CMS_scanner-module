################################################
# Auth : Kimkihoon
# edit_date : 2017.09.27
# description :
# 1.1.1 형식의 version list를 정렬한다.
# input - 각 버전의 이름이 담긴 배열
# output - 정렬된 각 버전의 이름이 담긴 배열
################################################
module Version_sort
  def version_sort(version_arr)
    def version_bubble_sort(start, finish, idx, array, version_arr)
        for i in start...finish
          for j in start...finish
            if array[j][idx].to_i > array[j+1][idx].to_i
              array[j], array[j+1] = array[j+1], array[j]
              version_arr[j], version_arr[j+1] = version_arr[j+1], version_arr[j]
            end
          end
        end
        return array
    end

    num_arr = Array.new()
    version_arr.each { |data| num_arr.push(data.gsub(/[a-z_]/,'').split('.'))}
    num_idx = 0
    num_arr.each{ |data|
      if(num_idx < data.length())
        num_idx = data.length()
      end
    }
    puts num_idx
    version_bubble_sort(0, num_arr.length()-1, 0, num_arr, version_arr)

    for i in 1...num_idx
      start_idx = 0
      for j in 0...num_arr.length()-1
        if(num_arr[j][i-1] != num_arr[j+1][i-1])
          version_bubble_sort(start_idx, j, i, num_arr, version_arr);
          start_idx = j+1;
        end
      end
      version_bubble_sort(start_idx, num_arr.length()-1, i, num_arr, version_arr);
    end

    return version_arr
  end
end
