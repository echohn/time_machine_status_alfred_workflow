# frozen_string_literal: true

require 'property-list'

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

    def         subtitle
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
    attr_reader :title, :subtitle
    def         initialize
      parse_status

      if running?
        parse_running_stage
      else
        set_not_running_output
      end
    end

    private

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

    def parse_status
      command_output = `tmutil status`.lines[1..-1].join
      @status = PropertyList.load_ascii(command_output)
      pp @status if DEBUG
    end

    def on_progress
      OnProgress.new(@status['Progress'])
    end

    def set_starting_output
      @title    = "正在准备备份..."
      @subtitle = "需要等待一段时间"
    end

    def set_pre_output
      puts "in set_pre_output" if DEBUG

      @title    = '正在执行预备份...'
      @subtitle = 'This process will be done soon'
    end

    def set_copying_output
      puts "in set_copying_output" if DEBUG

      progress  = on_progress
      @title    = progress.title
      @subtitle = progress.subtitle
    end

    def set_finishing_output
      puts "in set_finishing_output" if DEBUG

      progress  = on_progress
      @title    = "即将完成备份, 预计剩余 #{progress.time_remaining} 小时"
      @subtitle = "This process will be done soon"
    end

    def set_not_running_output
      puts "in set_not_running_output" if DEBUG

      @title    = "当前未在备份"
      @subtitle = "当前未在备份"
    end
  end

  module Status
    module_function

    def output
      parser = StatusParser.new
      OutputItem.new(uuid, order, parser.title, parser.subtitle, ICON)
    end

    def uuid
      'status'
    end

    def order
      1
    end
  end
end
