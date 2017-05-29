

print "===============================\n"
print "\t Scanner_MsfConsole \n"
print "===============================\n"

$:.unshift(File.join(File.dirname(__FILE__), '..' 'lib'))

require 'msf/base'
require 'msfenv'
require 'pry'

Indent = '  '
prompt = '> '

class Console

    def initilize
    end
    
    def search_module(mod_name)
    end
    
    def set_option(opts)
    end
    
    def show_options(to_see)
    end
    
    def use_module(mod_name)
    end
    
    def show_help
        tbl = Rex::Ui::Text::Table.new(
            'Header'    => 'Commands you can use',
            'Indent'    => Indent.length,
            'Coulmns'   => [ 'Command', 'Description' ] 
        )

        tbl << ['help', 'list available commands']
        tbl << ['quit', 'exit mini msfconsole']

        tbl.sort_rows(1)
        puts tbl.to_s
    end
    
end

cs = Console.new

begin
    print prompt
    select = gets.chomp.split


    case select.shift
        when /help/
            cs.show_help

        when /search/

        when /use/

        when /show/

        when /quit/
            break
        else
            print_error("unknown commands type 'help'")
     end

rescue
    print "error"
end while true