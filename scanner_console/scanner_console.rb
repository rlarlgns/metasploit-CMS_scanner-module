#! /usr/bin/env ruby

print "======================================\n"
print "\t Scanner_MsfConsole \n"
print "======================================\n"

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'msfenv'
require 'msf/base'

Indent = '  '
prompt = '> '

class Console

    def initilize
        @framework    = Msf::Simple::Framework.create
        @exploit_name = nil
        @payload_name = 'windows/meterpreter/reverse_tcp'
        @input        = Rex::Ui::Text::Input::Stdio.new
        @output       = Rex::Ui::Text::Output::Stdio.new
        @driver       = Msf::ExploitDriver.new(@framework)
    end

    def search_module(mod_name)
        regx = Regexp.new(mode_name)
        tbl = Rex::Ui::Text::Table.new()
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
          'Columns'   => ['Command', 'Description']
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
            cs.search_module(select[0])
        when /use/

        when /show/

        when /quit/
            break
        else
            print_error("unknown commands type 'help'")
     end
rescue
    print "error\n"
end while true
