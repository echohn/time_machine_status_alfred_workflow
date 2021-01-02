# frozen_string_literal: true

require 'json'

module TimeMachine
  class AlfredOutput
    attr_accessor :title_variable, :detail_variable
    def initialize
      @items = []
      @title_variable = '未知状态'
      @detail_variable = '未知状态'
    end

    def output
      {
        variables: {
          title:  @title_variable,
          detail: @detail_variable
        },
        items: @items
      }
    end

    def to_json
      output.to_json
    end

    def add_item(item)
      @items << item
    end
  end
end
