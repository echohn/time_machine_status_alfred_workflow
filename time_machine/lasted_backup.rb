# frozen_string_literal: true

module TimeMachine
  module LastedBackup
    module_function
    def command_output
      @command_output ||= `tmutil latestbackup`
    end

    def time_string
      # '2021-01-17-185931'
      @time_string ||= command_output.chomp.split(/\//).last.split(/\-/)
    end


    def last_backup_time
      @last_backup_time ||= Time.local(
        time_string[0].to_i,
        time_string[1].to_i,
        time_string[2].to_i,
        time_string.last[0..1].to_i,
        time_string.last[2..3].to_i,
        time_string.last[4..5].to_i
      )
    end

    def relative_backup_time
      relative_second = Time.now - last_backup_time
      case
      when relative_second > (3 * 86400)
        "#{relative_second / 86400} 天前"
      when relative_second > 3600
        "#{(relative_second.to_f / 3600).round(1)} 小时前"
      else
        "#{relative_second / 60} 分钟前"
      end
    end

    def exist?
      !!command_output
    end

    def output
      OutputItem.new(uuid, order, title, subtitle, ICON)
    end

    def uuid
      'lasted-backup'
    end

    def order
      2
    end

    def title
      if exist?
        "最近的备份：#{relative_backup_time}"
      else
        "未发现备份"
      end
    end

    def subtitle
      if exist?
        "最近的时间返回舱备份：#{last_backup_time.strftime('%Y-%m-%d %H:%M:%S')}"
      else
        "未找到已完成的备份"
      end
    end
  end
end
