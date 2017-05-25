##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require 'open-uri'

class MetasploitModule < Msf::Auxiliary

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'cms version scanner',
      'Description'    => %q{
        Say cms, plugin version scanner.
      },
      'Author'         => [ 'kim kihoon' ],
      'License'        => MSF_LICENSE
    ))
  end

  def hi()
    
  end
  
  def run
   puts "hello world"
  end

end