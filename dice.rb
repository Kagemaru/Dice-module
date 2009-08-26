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
	for i in 1..a_throw[:times]
		a_throw[:dice].push(rand(a_throw[:sides]) + 1)
		a_throw[:total] += a_throw[:dice].last
	end
	puts "a_throw[:output] 1:" if DEBUG
	pp(a_throw) if DEBUG
	a_throw[:output][:text] = a_throw[:dicestring].to_s + ": " +a_throw[:total].to_s
	a_throw[:total] += a_throw[:mod]

	puts "a_throw[:output] 2:" if DEBUG
	pp(a_throw) if DEBUG

	if a_throw[:options] then a_throw.evaloptions(a_throw[:options]) end
	#output = a_throw[:dice].join(", ") + " + " + a_throw[:mod].to_s + " = " + a_throw.total.to_s
	
	puts "a_throw[:output] 3:" if DEBUG
	pp(a_throw) if DEBUG
    
	puts a_throw[:output][:text] if a_throw[:output][:text]

	return a_throw[:total]
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


class Throw < Hash

	def initialize(times=1,sides=20,mod=0,options=nil,dicestring="1d20")
		self[:times]      = times
		self[:sides]      = sides
		self[:mod]        = mod
		self[:options]    = options
		self[:dice]       = []
		self[:total]      = 0
		self[:output]     = { :text => "" }
		self[:dicestring] = dicestring
	end


	def lowest(val=3)
		if (self[:dice].size < val) then range = 0..(size-1) else range = 0..(val-1) end
		tmp = self[:dice].clone
		values = tmp.sort[range]
		nr = []
		tmp2 = []
		for i in range
			nr.push(tmp.index(values.shift))
			tmp[nr.last] = 0
		end
		nr.sort.each { |n| tmp2.push(self[:dice][n]) }
		self[:dice] = tmp2
		return tmp2
	end


	def highest(*args)
		puts "args in highest: "
		pp(args)
		if args[0].kind_of?(Integer) then val = args[0] else val = 3 end
		puts args[0].to_s + " = " + val.to_s if DEBUG == "verbose"
		if (self[:dice].size < val)
			range = 0..(self[:dice].size-1)
			puts "self[:dice]: " if DEBUG == "verbose"
			puts "range = "+ range.to_s if DEBUG == "verbose"
		else
			range = 0..(val-1)
			puts "val = " + val.to_s
			puts "range = " + range.to_s
		end
		tmp = self[:dice].clone
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
		indices.sort.each { |n| tmp2.push(self[:dice][n]) }
		#self[:dice] = tmp2
		#self[:highest] = indices
		puts "self[:output]:"
		pp(self[:output])
		puts "tmp2:"
		pp(tmp2)
		self[:output][:highest] = "highest " +val.to_s+": " + color(tmp2.join(" "),:red)
		puts "tmp2:" if DEBUG == "verbose"
		pp(tmp2) if DEBUG == "verbose"
		return tmp2
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
				pp(self[:dice])
				if self.respond_to?(k.to_sym) then evaltext += evaltmp+"\n" end
			end
		end
		puts "evaltext before return: "+evaltext
		eval(evaltext)
	end


	def total
		self[:total] = 0
		self[:dice].each do |d|
			self[:total] += d
		end
		self[:total] += self[:mod]
		return self[:total]
	end


	def full
		self.total
		output = ""
		self[:output].each do
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
		pp(self[:dicestring]) if DEBUG
		output += self[:dicestring]+": "
		output += self[:dice].join(", ")
		output += " + "+self[:mod].to_s if self[:mod] > 0
		output += " - "+(self[:mod] * -1).to_s if self[:mod] < 0
		output += " = "+self[:total].to_s
		self[:output][:text] = output
	end

end


begin #main
	puts "------------------ Entering Main ------------------" if DEBUG == "verbose"
	#puts "coin: " + ((rand(2) == 0)?"heads":"tails").to_s
	roll("10d4+1.highest(5)")
	#puts "5d6 (each):" + roll_dice("5d6+7","each").to_s
#	puts "2d4-1: " + roll("2d4-1").to_s
	puts "------------------ End of Main ------------------" if DEBUG == "verbose"
end
