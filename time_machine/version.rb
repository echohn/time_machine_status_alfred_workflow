# frozen_string_literal: true

module TimeMachine
  module Version
    SUPPORT_VERSIONS = ['4.0.0'].freeze

    module_function
    def version
      @version ||= get_version
    end

    def support?
      SUPPORT_VERSIONS.include? version
    end

    def output
      {
        uid: 'version',
        title: title,
        detail: detail,
        icon: {
          path: ICON
        }
      }
    end

    def title
      "tmutil version: #{version}"
    end

    def detail
      if support?
        "这个版本支持的"
      else
        "WARNING: 这个版本没测试过"
      end

    end

    def get_version
      the_version = `tmutil version`.lines.first.match(/tmutil version (\d+\.\d+\.\d)/)&.[](1)
      puts "#{__class__} #{__method__}: #{the_version}" if DEBUG
      the_version
    end
  end
end
