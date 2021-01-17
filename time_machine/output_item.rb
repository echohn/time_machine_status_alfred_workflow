# frozen_string_literal: true

module TimeMachine
  OutputItem =
    Struct.new(:uuid, :order, :title, :subtitle, :icon) do
      def output
        {
          title:    title,
          subtitle: subtitle,
          icon: {
            path: icon
          }
        }
      end
    end
end
