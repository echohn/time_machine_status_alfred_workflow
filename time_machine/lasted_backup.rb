# frozen_string_literal: true

module TimeMachine
  module LastedBackup
    module_function
    def command_output
      @command_output ||= `tmutil latestbackup`
    end

    def last_backup_time
      @last_backup_time ||= command_output.chomp.split(/\//).last.split(/\-/)
    end

    def exist?
      !!command_output
    end

    def output
      {
        uid: 'version',
        title: title,
        subtitle: detail,
        icon: {
          path: ICON
        }
      }
    end

    def title
      if exist?
        '备份已完成'
      else
        "未找到备份"
      end
    end

    def detail
      if exist?
        "最近的时间返回舱备份：#{ last_backup_time[1] }月#{ last_backup_time[2] }日 #{last_backup_time.last[0..1]}:#{last_backup_time.last[2..3]}"
      else
        "未找到已完成的备份"
      end
    end
  end
end
