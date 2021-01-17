# frozen_string_literal: true

require_relative 'time_machine/status'
require_relative "time_machine/alfred_output"
require_relative "time_machine/version"
require_relative "time_machine/destination"
require_relative "time_machine/lasted_backup"

module TimeMachine
  DEBUG = false
  ICON  = 'TimeMachine.icns'

  module_function

  def to_alfred
    info.to_json
  end

  def info
    output = AlfredOutput.new

    threads = [Status, Destination, LastedBackup, Version].map do |the_module|
      Thread.new do
        output.add_item(the_module.output)
      end
    end

    threads.map(&:join)

    output
  end
end
