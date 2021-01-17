#!/usr/bin/env ruby

# frozen_string_literal: true

($LOAD_PATH << File.expand_path("..", __FILE__)).uniq!

require "bundle/bundler/setup"
require_relative './time_machine.rb'

puts TimeMachine.to_alfred
