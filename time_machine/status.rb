# frozen_string_literal: true

require 'property-list'

require_relative "alfred_output"
require_relative "version"
require_relative "destination"

module TimeMachine
  class OnProgress
    attr_reader :time_remaining
    def initialize(progress)
      @time_remaining = second_to_hour progress['TimeRemaining']
      @percent        = to_percent progress['Percent']
      @bytes          = bytes_to_gb progress['bytes']
      @totalBytes     = bytes_to_gb progress['totalBytes']
      @files          = number_with_delimiter progress['files']
      @totalFiles     = number_with_delimiter progress['totalFiles']
    end

    def title
      "备份中, 预计剩余 #{@time_remaining} 小时"
    end

    def detail
      "进度 #{@percent}%, Bytes: #{@bytes} GB / #{@totalBytes} GB, Files: #{@files} / #{@totalFiles}"
    end

    private

    def number_with_delimiter(value)
      value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
    end

    def bytes_to_gb(value)
      (value.to_f / 1000 / 1000 / 1000).round(2)
    end

    def second_to_hour(value)
      (value.to_i / 60.0 / 60.0).round(2)
    end

    def to_percent(value)
      (value.to_f * 100).round(2)
    end
  end

  class StatusParser
    def initialize
      parse_status
    end

    def output
      parse_running_stage

      {
        uid: 'status',
        title: @title,
        subtitle: @detail,
        icon: {
          path: ICON
        }
      }
    end

    def running?
      @status['Running'] == '1'
    end

    def parse_running_stage
      puts "in analyze_running_status" if DEBUG

      case @status["BackupPhase"]
      when "Starting"
        set_starting_output
      when "ThinningPreBackup"
        set_pre_output
      when "Copying"
        set_copying_output
      when "Finishing"
        set_finishing_output
      end
    end

    private

    def parse_status
      command_output = `tmutil status`.lines[1..-1].join
      @status = PropertyList.load_ascii(command_output)
      pp @status if DEBUG
    end

    def on_progress
      OnProgress.new(@status['Progress'])
    end

    def set_starting_output
      @title = "正在准备备份..."
      @detail = "需要等待一段时间"
    end

    def set_pre_output
      puts "in set_pre_output" if DEBUG

      @title = '正在执行预备份...'
      @detail = 'This process will be done soon'
    end

    def set_copying_output
      puts "in set_copying_output" if DEBUG

      progress = on_progress
      @title   = progress.title
      @detail  = progress.detail
    end

    def set_finishing_output
      puts "in set_finishing_output" if DEBUG

      progress = on_progress
      @title = "即将完成备份, 预计剩余 #{progress.time_remaining} 小时"
      @detail  = "This process will be done soon"
    end
  end

  module Status
    module_function
    def output
      output = AlfredOutput.new

      unless Version.support?
        output.add_item Version.output
        return output
      end

      status = StatusParser.new

      if status.running?
        output.title_variable  = status.output[:title]
        output.detail_variable = status.output[:detail]
        output.add_item status.output
        output.add_item Destination.output
      else
        output.add_item LastedBackup.output
      end

      output
    end
  end
end
