# -*- coding: utf-8 -*-
$LOAD_PATH << File.dirname(__FILE__)

require 'active_record'
require 'slack-notifier'
require 'yahoo_transit'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)

class Train < ActiveRecord::Base; end

def notify_string(name:, time:, description:, url:)
detail = url ? "\n<#{url}|Detail>" : ""
<<EOS
遅延情報 : #{name}
#{time.to_s}

#{description}#{detail}
EOS
end

def notify(str)
  $notifier.ping str
end



$notifier = Slack::Notifier.new "https://hooks.slack.com/services/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"
$notifier.ping "Bot started"


yt = YahooTransit.new
while true
  list = yt.scrape
  delayed = Hash[*list.map {|y| [y[:name], y]}.flatten]
  Train.all.each do |t|
    next unless t.watching
    unless delayed[t.name]
      if t.time != nil
        n = notify_string(name: t.name, time: Time.now, description: "復旧しました！")
        notify(n)
        t.time = nil
        t.save!
      end
      next
    end
    d = delayed[t.name]
    next if t.description.nil? == false && d[:description] == t.description
    t.time = d[:time]
    t.description = d[:description]
    t.save!
    notify(notify_string(d))
  end
  sleep 5.minutes
end
