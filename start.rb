#!/usr/bin/env ruby

require_relative 'lib/dash'

$threads = []
DASH::Server.new File.read("config.yaml")

sleep
$threads.map(&:join)