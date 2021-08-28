require 'irb/completion'
require 'rubygems'

# Autoload all gems in the Gemfile default set
require 'bundler/setup'
Bundler.require(:default)

# TODO: find a valid editor if it's not set and config it's 'edit at line' and terminal req'ts
# Make sure $EDITOR is set
ENV['EDITOR'] = 'code' unless ENV['EDITOR']

# ActiveRecord::Base.logger.level = 1 if defined?(ActiveRecord)
IRB.conf[:SAVE_HISTORY] = 1000

# Overriding Object class
class Object
  # Easily print methods local to an object's class by filtering out some ancestor
  def lm(filter_type=self.class.superclass)
    filter_type = Object unless filter_type
    filter_type = filter_type.class unless filter_type.class == Class

    (methods - filter_type.instance_methods).sort
  end

  # look up source location of a method
  def sl(method_name)
    self.method(method_name).source_location rescue "#{method_name} not found"
  end

  # open particular method in vs code
  def ocode(method_name)
    file, line = self.sl(method_name)
    if file && line
      system("${EDITOR} -g '#{file}:#{line}'")
    else
      "'#{method_name}' not found :(Try #{self.name}.lm to see available methods"
    end
  end

  # display method source in rails console
  def ds(method_name)
    self.method(method_name).source.display
  end

  # open json object in VS Code Editor
  def oo
    unless Object.const_defined?(:Rails)
      "You're not using Rails right now"
      return
    end
    tempfile = File.join(Rails.root.join('tmp'), SecureRandom.hex)
    File.open(tempfile,'w') {|f| f << self.as_json}
    system("${EDITOR} #{tempfile}")
    sleep(1)
    File.delete( tempfile )
  end
end

# history command
def hist(count = 0)
  # Get history into an array
  history_array = Readline::HISTORY.to_a

  # if count is > 0 we'll use it.
  # otherwise set it to 0
  count = count > 0 ? count : 0

  if count > 0
    from = history_array.length - count
    history_array = history_array[from..-1]
  end

  print history_array.join("\n")
end

# copy a string to the clipboard
def cp(string)
  `echo "#{string}" | pbcopy`
  puts "copied in clipboard"
end

# reloads the irb console can be useful for debugging .irbrc
def reload_irb
  load File.expand_path("~/.irbrc")
  # will reload rails env if you are running ./script/console
  reload! if @script_console_running
  puts "Console Reloaded!"
end

# opens irbrc in vscode
def edit_irb
  system("${EDITOR} #{IRB.conf['IRBRC']}")
end

def bm
  # From http://blog.evanweaver.com/articles/2006/12/13/benchmark/
  # Call benchmark { } with any block and you get the wallclock runtime
  # as well as a percent change + or - from the last run
  cur = Time.now
  result = yield
  print "#{cur = Time.now - cur} seconds"
  puts " (#{(cur / $last_benchmark * 100).to_i - 100}% change)" rescue puts ""
  $last_benchmark = cur
  result
end

# exit using `q`
alias q exit

# all available methods explaination
def ll
  puts '============================================================================================================='
  puts 'Welcome to rails console. Here are few list of pre-defined methods you can use.'
  puts '============================================================================================================='
  puts 'obj.sl(:method) ------> source location e.g lead.sl(:name)'
  puts 'obj.ocode(:method) ---> open method in vs code e.g lead.ocode(:name)'
  puts 'obj.dispsoc(:method) -> display method source in rails console e.g lead.dispsoc(:name)'
  puts 'obj.oo ---------------> open object json in vs code e.g lead.oo'
  puts 'hist(n) --------------> command history e.g hist(10)'
  puts 'cp(str) --------------> copy string in clipboard e.g cp(lead.name)'
  puts 'bm(block) ------------> benchmarking for block passed as an argument e.g bm { Lead.all.pluck(:stage);0 }'
  puts '============================================================================================================='
end
