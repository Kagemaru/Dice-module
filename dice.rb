#!/usr/bin/ruby
require 'pp'


=begin ToDo list
Rolls:
[x] normal die
[x] minimum die
[x] maximum die
[x] Action Dice
[x] extra (bonus die on value >= X)
[x] open  (bonus die on value >= X, on bonus dice too)

Modifications:
[x] highest X values
[x] lowest X values
[x] hits (count values >= X)
=end


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
		if min == nil then puts "you need to give a minimum roll."; return -1 end
		for i in 0...times do
			@rolls[i] = Dice.new
			for j in 0...@times
				while @rolls[i][j].to_i < min do @rolls[i][j] = rand(@sides) + 1 end
			end
		end
		puts "@rolls:" if DEBUG == "verbose"
		pp(@rolls) if DEBUG == "verbose"
		return @rolls
	end


	def maxroll(max, times=1)
		if max == nil then puts "you need to give a maximum roll."; return -1 end
		for i in 0...times do
			@rolls[i] = Dice.new
			for j in 0...@times
				while @rolls[i][j].to_i > max || @rolls[i][j].to_i == 0 do @rolls[i][j] = rand(@sides) + 1 end
			end
		end
		puts "@rolls:" if DEBUG == "verbose"
		pp(@rolls) if DEBUG == "verbose"
		return @rolls
	end

	
	def actiondice(times=1)
		for i in 0...times do
			@rolls[i] = Dice.new
			for j in 0...@times
				@rolls[i][j] = rand(@sides) + 1
				tmp = [@rolls[i][j]]
				while tmp.last == 1 || tmp.last == @sides do
					tmp.push(rand(@sides) + 1) 
				end
				tmp = tmp[0] if tmp.size == 1
				@rolls[i][j] = tmp
			end
		end
		puts "@rolls:" if DEBUG == "verbose"
		pp(@rolls) if DEBUG == "verbose"
		return @rolls
	end


	def extra(bonus,times=1)
		for i in 0...times do
			@rolls[i] = Dice.new
			for j in 0...@times
				@rolls[i][j] = rand(@sides) + 1
				if @rolls[i][j] >= bonus then 
					tmp = [@rolls[i][j]]
					tmp.push(rand(@sides) + 1) 
					tmp = tmp[0] if tmp.size == 1
					@rolls[i][j] = tmp
				end
			end
		end
		puts "@rolls:" if DEBUG == "verbose"
		pp(@rolls) if DEBUG == "verbose"
		return @rolls
	end


	def open(bonus,times=1)
		for i in 0...times do
			@rolls[i] = Dice.new
			for j in 0...@times
				@rolls[i][j] = rand(@sides) + 1
				tmp = [@rolls[i][j]]
				while tmp.last >= bonus do
					tmp.push(rand(@sides) + 1) 
				end
				tmp = tmp[0] if tmp.size == 1
				@rolls[i][j] = tmp
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
		
	def lowest(val=3,type=nil)
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
		if type == "index"
			return indices
		else
		    pp(indices) if DEBUG == "verbose"
			indices.sort.each { |n| tmp2.push(self[n]) }
			return tmp2
		end
	end


	def highest(val=3, type=nil)
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
		if type == "index"
			return indices
		else
			pp(indices) if DEBUG == "verbose"
			indices.sort.each { |n| tmp2.push(self[n]) }
			return tmp2
		end
	end


	def hits(limit=15,type=nil)
		indices = Array.new
		for i in 0...self.size
			if self[i] >= limit
				indices.push(i)
			end
		end
		if type == "index"
			return indices
		elsif type == "numbers"
			output = []
			indices.each { |v| output.push(self[v]) }
			return output
		else
			return indices.size
		end
	end

end

#/Class Definitions


def menu(rolls)
	menu =<<EOT
	Rolls:
	\t[a][#{rolls["type"] == "normal" ? "X" : " "}] normal die
	\t[b][#{rolls["type"] == "min" ? "X" : " "}] minimum die
	\t[c][#{rolls["type"] == "max" ? "X" : " "}] maximum die
	\t[d][#{rolls["type"] == "AD" ? "X" : " "}] Action Dice
	\t[e][#{rolls["type"] == "extra" ? "X" : " "}] extra (bonus die on value >= X)
	\t[f][#{rolls["type"] == "open" ? "X" : " "}] open  (bonus die on value >= X, on bonus dice too)

	Modifications:
	\t[g][#{rolls["opts"]["highest"] ? "X" : " "}] highest X values
	\t[h][#{rolls["opts"]["lowest"] ? "X" : " "}] lowest X values
	\t[i][#{rolls["opts"]["hits"] ? "X" : " "}] hits (count values >= X)
	
	Values:
	\t[j] Roll x times: #{rolls["times"] ? rolls["times"] : " "}
	\t[k] Dice: #{rolls["dice"] ? rolls["dice"] : " "}

	Actions:
	\t[r] Roll Dice
	\t[z] Exit
EOT
end


if __FILE__ == $0 #main
	if DEBUG == "verbose"
		puts "------------------ Entering Main ------------------"
		puts "\n\nRolls:"
		puts "------------------- Flip Coin: --------------------"
		puts flip_coin	
		puts "---------------------------------------------------"
		puts "------------------ Normal Roll: -------------------"
		test = Throw.new("5d20+1")
		test.roll(2)
		pp(test.rolls)
		puts "---------------------------------------------------"
		puts "-------------- Minimum Roll (5d4+1): --------------"
		mintest = Throw.new("5d4+1")
		mintest.minroll(2,2)
		pp(mintest.rolls)
		puts "---------------------------------------------------"
		puts "------------- Maximum Roll (5d20+1): --------------"
		maxtest = Throw.new("5d20+1")
		maxtest.maxroll(4,2)
		pp(maxtest.rolls)
		puts "---------------------------------------------------"
		puts "--------------- Action Dice (5d4): ----------------"
		adtest = Throw.new("5d4")
		adtest.actiondice(2)
		pp(adtest.rolls)
		puts "---------------------------------------------------"
		puts "-------------- Extra Roll: (5d20): ----------------"
		extratest = Throw.new("5d20")
		extratest.extra(15,2)
		pp(extratest.rolls)
		puts "---------------------------------------------------"
		puts "--------------- Open Roll: (5d20): ----------------"
		opentest = Throw.new("5d20+1")
		opentest.open(15,2)
		pp(opentest.rolls)
		puts "------------------- End of Rolls ------------------"
		puts "-------------------- Modifiers: -------------------"
		puts "rolls to modify:"
		pp(test.rolls)
		puts "--------------------- Lowest: ---------------------"
		puts "Roll 1:"
		pp(test.rolls[0].lowest)
		puts "Roll 2:"
		pp(test.lowest)
		puts "--------------------- Highest: --------------------"
		puts "Roll 1:"
		pp(test.rolls[0].highest)
		puts "Roll 2:"
		pp(test.highest)
		puts "---------------------- Hits: ----------------------"
		puts "Roll 1:"
		pp(test.rolls[0].hits)
		puts "Roll 2:"
		pp(test.rolls[1].hits)
		puts "----------------- End of Modifiers ----------------"
		puts "------------------- End of Main -------------------"
	else
		rolls = {}
		rolls["opts"] = {}
		quit = false
		while quit != true
			puts menu(rolls)
			choice = gets.chomp
			case choice
				when 'a': rolls["type"] = "normal" 
				when 'b': rolls["type"] = "min"
				when 'c': rolls["type"] = "max"
				when 'd': rolls["type"] = "AD"
				when 'e': rolls["type"] = "extra"
				when 'f': rolls["type"] = "open"
				when 'g': 
					if rolls["opts"]["highest"] then rolls["opts"]["highest"] = false
					else rolls["opts"]["highest"] = true; rolls["opts"]["lowest"] = false; end
				when 'h':
					if rolls["opts"]["lowest"] then rolls["opts"]["lowest"] = false;
					else rolls["opts"]["lowest"] = true; rolls["opts"]["highest"] = false; end
				when 'i': 
					if rolls["opts"]["hits"] then rolls["opts"]["hits"] = false
					else rolls["opts"]["hits"] = true end
				when 'j': 
						tmp = gets.chomp.to_i
						if tmp =~ /\d/
				when 'k':
				when 'r': 
				when 'z': quit = true
			end
		end
	end
end
