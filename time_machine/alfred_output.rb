# frozen_string_literal: true

require 'json'
require_relative './status.rb'

module TimeMachine
  class AlfredOutput
    attr_accessor :var_title, :var_detail

    def initialize
      @items      = []
      @var_title  = '未知状态'
      @var_detail = '未知状态'
    end

    def output
      {
        variables: {
          title:  @var_title,
          detail: @var_detail
        },
        items: items_output
      }
    end

    def items_output
      @items.sort_by(&:order).map(&:output)
    end

    def to_json
      output.to_json
    end

    def add_item(item)
      @items << item

      return unless item.uuid == Status.uuid

      @var_title  = item.title
      @var_detail = item.subtitle
    end
  end
end
