#!/usr/bin/ruby
require 'pp'


#Define vars
DEBUG = true 
#/Define vars


#General Method Definitions

def flip_coin
	if (rand(2) == 0) then return "heads" else return "tails" end
end


def roll(dicestring="1d20")
	if dicestring =~ /(\d+)?d(\d+)(\+\d+|\-\d+)?(\..+)?/i
		puts "$1: #{$1}; $2: #{$2}; $3: #{$3}; $4: #{$4}" if DEBUG == "verbose"
		times   = (($1.nil?)?1:$1).to_i
		sides   = (($2.nil?)?20:$2).to_i
		mod     = (($3.nil?)?0:$3).to_i
		options = []
		if $4 #scan for options
			$4.scan(/\.[^.]*/i).each do
				|m|
				if m =~ /\((.*)\)/i
					puts "options[:#{m.scan(/[^.(]*/i)[1]}] => #{m.match(/\((.*)\)/i)[1] }" if DEBUG == "verbose"
					options.push({ m.scan(/[^.(]*/i)[1].to_sym => m.match(/\((.*)\)/i)[1].split(",")})
				else
					puts "options[:#{m.scan(/[^.(]*/i)[1]}] => nil}" if DEBUG == "verbose"
					options.push({ m.scan(/[^.(]*/i)[1].to_sym => nil})
				end
			end
		end
		#die     = dicestring.match(/\d*d\d+((\+|\-)\d+)?/)
		a_throw = Throw.new(times,sides,mod,options,dicestring)
	else
		puts "Invalid String!"
	end	
	for i in 1..a_throw.times
		a_throw.dice.push(rand(a_throw.sides) + 1)
		a_throw.total += a_throw.dice.last
	end
	puts "a_throw.output 1:" if DEBUG
	pp(a_throw) if DEBUG
	a_throw.output[:text] = a_throw.dicestring.to_s + ": " +a_throw.total.to_s
	a_throw.total += a_throw.mod

	puts "a_throw[:output] 2:" if DEBUG
	pp(a_throw) if DEBUG

	if a_throw.options then a_throw.evaloptions(a_throw.options) end
	#output = a_throw[:dice].join(", ") + " + " + a_throw[:mod].to_s + " = " + a_throw.total.to_s
	
	puts "a_throw.output 3:" if DEBUG
	pp(a_throw) if DEBUG
    
	puts a_throw.output[:text] if a_throw.output[:text]

	return a_throw.total
end


def color(s,c)
	color = "["
	case c
		when :red : color += "31"
		when :green : color += "32"
	end
	color += "m"
	return color + s.to_s + " [0m"
end

#End of General Method Definitions


#Class Definitions

class Throw
    attr_accessor :times, :sides, :mod, :options, :rolls, :total, :output, :dicestring
	def initialize(dicestring="1d20")
		if dicestring =~ /(\d+)?d(\d+)(\+\d+|\-\d+)?/i
			puts "$1: #{$1}; $2: #{$2}; $3: #{$3}; $4: #{$4}" if DEBUG == "verbose"
			@times   = (($1.nil?)?1:$1).to_i
			@sides   = (($2.nil?)?20:$2).to_i
			@mod     = (($3.nil?)?0:$3).to_i
			@options = []
		end
		@rolls      = []
		@total      = 0
		@output     = { :text => "" }
		@dicestring = dicestring
	end

	
	def roll(times=1)
		for i in 0...times do
			@rolls[i] = Dice.new
			for j in 0...@times
				@rolls[i].push(rand(@sides) + 1)
			end
		end
		puts "@rolls:" if DEBUG == "verbose"
		pp(@rolls) if DEBUG == "verbose"
		return @rolls
	end


	def minroll(min, times=1)
		if min == nil then puts "you need to give a minimum roll." end
		for i in 0...times do
			@rolls[i] = Dice.new
			for j in 0...@times
				@rolls[i][j] = rand(@sides) + 1
				while @rolls[i][j] < min do @rolls[i][j] = rand(@sides) + 1 end
			end
		end
		puts "@rolls:" if DEBUG == "verbose"
		pp(@rolls) if DEBUG == "verbose"
		return @rolls
	end


	def total
		@total = 0
		@dice.each do |d|
			@total += d
		end
		@total += self[:mod]
		return @total
	end


	def full
		self.total
		output = ""
		@output.each do
			|k,v|
			if k == :text then next end
			puts "k = " if
			pp(k) if DEBUG
			puts "v = " if DEBUG
			pp(v) if DEBUG
			output += v.to_s
			output += "\n"
		end
		puts "dicestring in full:" if DEBUG
		pp(@dicestring) if DEBUG
		output += @dicestring+": "
		output += @dice.join(", ")
		output += " + "+@mod.to_s if @mod > 0
		output += " - "+(@mod * -1).to_s if @mod < 0
		output += " = "+@total.to_s
		@output[:text] = output
	end

	
	def highest(*args)
		return @rolls.last.highest if args.nil?
		return @rolls.last.highest(*args)
	end


	def lowest(*args)
		return @rolls.last.lowest if args.nil?
		return @rolls.last.lowest(*args)
	end

end


class Dice < Array
	def lowest(*args)
		if args[0].kind_of?(Integer) then val = args[0] else val = 3 end
		if (self.size < val)
			range = 0...self.size
			puts "self: " if DEBUG == "verbose"
			puts "range = "+ range.to_s if DEBUG == "verbose"
		else
			range = 0...val
			puts "val = " + val.to_s if DEBUG == "verbose"
			puts "range = " + range.to_s if DEBUG == "verbose"
		end
		tmp = self.clone
		values = tmp.sort[range]
		indices = []
		tmp2 = []
		for i in range
			indices.push(tmp.index(values.shift))
			tmp[indices.last] = 0
		end
		if args[1] == "index"
			return indices
		else
		    pp(indices) if DEBUG == "verbose"
			indices.sort.each { |n| tmp2.push(self[n]) }
			return tmp2
		end
	end


	def highest(*args)
		if args[0].kind_of?(Integer) then val = args[0] else val = 3 end
		if (self.size < val)
			range = 0...self.size
			puts "self: " if DEBUG == "verbose"
			puts "range = "+ range.to_s if DEBUG == "verbose"
		else
			range = 0...val
			puts "val = " + val.to_s if DEBUG == "verbose"
			puts "range = " + range.to_s if DEBUG == "verbose"
		end
		tmp = self.clone
		values = tmp.sort.reverse[range]
		indices = []
		tmp2 = []
		for i in range
			indices.push(tmp.index(values.shift))
			tmp[indices.last] = 0
		end
		if args[1] == "index"
			return indices
		else
			pp(indices) if DEBUG == "verbose"
			indices.sort.each { |n| tmp2.push(self[n]) }
			return tmp2
		end
=begin
		puts "args in highest: " if DEBUG == "verbose"
		pp(args) if DEBUG == "verbose"
		if args[0].kind_of?(Integer) then val = args[0] else val = 3 end
		puts args[0].to_s + " = " + val.to_s if DEBUG == "verbose"
		if (@dice.size < val)
			range = 0..(@dice.size-1)
			puts "@dice: " if DEBUG == "verbose"
			puts "range = "+ range.to_s if DEBUG == "verbose"
		else
			range = 0..(val-1)
			puts "val = " + val.to_s
			puts "range = " + range.to_s
		end
		tmp = @dice.clone
		puts "tmp:"
		pp(tmp)
		values = tmp.sort.reverse[range]
		indices = []
		tmp2 = []
		for i in range
			indices.push(tmp.index(values.shift))
			tmp[indices.last] = 0
		end
		puts "indices:" if DEBUG == "verbose"
		pp(indices) if DEBUG == "verbose"
		indices.sort.each { |n| tmp2.push(@dice][n) }
		#@dice = tmp2
		#@highest = indices
		puts "@output:"
		pp(@output)
		puts "tmp2:"
		pp(tmp2)
		#@output][:highest = "highest " +val.to_s+": " + color(tmp2.join(" "),:red)
		puts "tmp2:" if DEBUG == "verbose"
		pp(tmp2) if DEBUG == "verbose"
		return tmp2
=end
	end

end

#/Class Definitions


begin #main
	puts "------------------ Entering Main ------------------" if DEBUG == "verbose"
	#puts "coin: " + ((rand(2) == 0)?"heads":"tails").to_s
	#roll("10d4+1.highest(5)")
	#puts "5d6 (each):" + roll_dice("5d6+7","each").to_s
#	puts "2d4-1: " + roll("2d4-1").to_s
	test = Throw.new("5d20+1")
	test.roll(2)
	pp(test.rolls)
	mintest = Throw.new("5d4+1")
	mintest.minroll(2,2)
	pp(mintest.rolls)
	puts "------------------ End of Main ------------------" if DEBUG == "verbose"
end







=begin
			if $4 #scan for options
				$4.scan(/\.[^.]*/i).each do
					|m|
					if m =~ /\((.*)\)/i
						puts "@options][:#{m.scan(/[^.(]*/i)[1]} => #{m.match(/\((.*)\)/i)[1] }" if DEBUG == "verbose"
						@options].push({ m.scan(/[^.(]*/i)[1.to_sym => m.match(/\((.*)\)/i)[1].split(",")})
					else
						puts "@options][:#{m.scan(/[^.(]*/i)[1]} => nil}" if DEBUG == "verbose"
						@options].push({ m.scan(/[^.(]*/i)[1.to_sym => nil})
					end
				end
			end








	def evaloptions(options)
		evaltext = ""
		pp(options) if DEBUG == "verbose"
		
		options.each do |p|
			pp(p) if DEBUG == "verbose"
			p.each do |k,v|
				evaltmp  = "self."
				evaltmp += k.to_s
				evaltmp += "("+ v.join(",") +")" if v
				puts "k + evaltmp after case: "+k.to_s+" , "+ evaltmp if DEBUG == "verbose"
				puts self.respond_to?(k.to_sym)
				pp(@dice)
				if self.respond_to?(k.to_sym) then evaltext += evaltmp+"\n" end
			end
		end
		puts "evaltext before return: "+evaltext
		eval(evaltext)
	end


=end
