require 'pseudo-console-cf-plugin'
require 'eventmachine'
require 'termios'
require 'stringio'
require 'base64'
require 'json'
require 'zlib'
require 'faye'

module Faye

  class Transport::Http < Transport

    def request(envelopes)

      content = encode(envelopes)
      params  = build_params(@endpoint, content)
      request = create_request(params)

      request.callback do
        handle_response(request.response, envelopes)
        store_cookies(request.response_header['SET_COOKIE'])
      end

    end

  private 

    def handle_response(response, envelopes)
      message = MultiJson.load(response) rescue nil
      if message
        receive(envelopes, message)
      else
        handle_error(envelopes)
      end
    end

  end
end

module PseudoConsoleCfPlugin

  include EM::Protocols::LineText2

  class KeyboardHandler < EM::Connection
    
    include EM::Protocols::LineText2

    def initialize(client, guid, console_type)
      @client = client
      @guid = guid
      @console_type = console_type
      @buffer = ''
    end

    def receive_line(data)
      EM.stop if data == "exit"
      @client.publish "/commands/#{@guid}", { :command => data.gsub("\n", ""), :console_type => @console_type }
    end

    def move_history(direction)
      puts direction
    end

    # def receive_data(char)
    #   @buffer << char

    #   if @buffer[0] == "\e" and @buffer.length == 3

    #     move_history('up') if @buffer[1] == "]" and @buffer[2] == "A"
    #     move_history('down') if @buffer[1] == "]" and @buffer[2] == "B"
        
    #     @buffer = ''
    #   end

    #   if char == "\n" and @buffer[0] != "\e"
    #     receive_line(@buffer) 
    #     @buffer = ''
    #   end

    # end

    # def receive_data keystrokes
    #   puts "I received the following data from the keyboard: #{keystrokes}"
    # end

  end
    
  class Plugin < CF::CLI
    
    def precondition
      # skip all default preconditions
    end

    desc "Open a pseudo console to an application container"
    group :admin
    input :app, :desc => "Application to connect to", :argument => true,
          :from_given => by_name(:app)
    input :faye_endpoint, :desc => "Faye endpoint to use", :argument => true
    input :instance, :desc => "Instance (index) to connect", :default => 0
    input :console_type, :desc => "The type of console, ruby or bash", :default => 'bash'

    def pseudo_console

      app = input[:app]

      app_version = app.manifest[:entity][:version]
      guid = "#{app_version}/#{input[:instance]}"
      start_connection(guid, input[:faye_endpoint], input[:console_type])

    end

    private

    def start_connection(guid, faye_endpoint, console_type)
      
      EM.run {

        # attributes = Termios.tcgetattr($stdin).dup
        # # # attributes.lflag &= ~Termios::ECHO
        # attributes.lflag &= ~Termios::ICANON
        # Termios::tcsetattr($stdin, Termios::TCSANOW, attributes)

        client = Faye::Client.new(faye_endpoint)

        client.subscribe("/responses/#{guid}") do |response|

          enc = Base64.decode64(response['text'])
          clear = Zlib::Inflate.inflate(enc)

          print clear
          print "\n> "

        end

        print "\n> "        
        
        EM.open_keyboard(KeyboardHandler, client, guid, console_type)
      }

    end

  end
end