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
        title: notsupport_title,
        detail: notsupport_detail,
        icon: {
          path: ICON
        }
      }
    end

    def notsupport_title
      "WARNING: tmutil command version not support"
    end

    def notsupport_detail
      "tmutil version is: #{version}"
    end

    def get_version
      the_version = `tmutil version`.lines.first.match(/tmutil version (\d+\.\d+\.\d)/)&.[](1)
      puts "#{__class__} #{__method__}: #{the_version}" if DEBUG
      the_version
    end
  end
end
