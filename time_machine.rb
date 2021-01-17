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

    status_output = Status.output

    output.title_variable  = status_output[:title]
    output.detail_variable = status_output[:detail]

    output.add_item status_output
    output.add_item Destination.output
    output.add_item LastedBackup.output
    output.add_item Version.output

    output
  end
end
