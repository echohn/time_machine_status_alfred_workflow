# frozen_string_literal: true

require_relative './output_item'

module TimeMachine
  class DestinationParser

    def initialize
      @command_output = `tmutil destinationinfo`.lines[1..-1]
      @name  = parse_output('Name')
      @kind  = parse_output('Kind')
      @url   = parse_output('URL')
      @mount = parse_output('Mount Point')
      @id    = parse_output('ID')
    end

    def title
      "备份磁盘 #{@name}"
    end

    def subtitle
      "类型: #{@kind}, 挂载点: #{@mount}, URL: #{@url}"
    end

    private

    def parse_output(parse_string)
      the_matcher =
        @command_output
        .map {|x| x.chomp.match(/^#{parse_string}\s+:\s(.*)/)}
        .compact
        .first
      the_matcher[1] if the_matcher
    end
  end

  module Destination
    module_function
    def output
      parser = DestinationParser.new
      OutputItem.new(uuid, order, parser.title, parser.subtitle, ICON)
    end

    def uuid
      'destinationinfo'
    end

    def order
      3
    end
  end
end
