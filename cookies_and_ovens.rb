class Oven
	attr_reader :sheet_length, :sheet_width
	attr_accessor :batch

	# baking sheet has length and width
	# cookies are measured as squares (diameter ** 2)
	# a sheet can fit as many cookies as each side's length / cookie diameter
	# we'll provide a default full-size baking sheet of 26"x18"
	# but allow the user to input a different size
	def initialize(length=26, width=18)
		@sheet_length = length
		@sheet_width = width
		@batch = []
	end 

	def capacity(cookie)
		(@sheet_length / cookie.size) * (@sheet_width / cookie.size)
	end

	# returns true if there's enough space in the batch
	def capacity?(cookie)
		capacity(cookie) > @batch.size
	end

	# instantiate a new cookie
	# will allow for different types eventually
	def new_cookie
		Peanut.new
	end

	def create_batch!
		@batch << new_cookie
		create_batch! until !capacity?(new_cookie)
	end

	def bake!
		@batch.map { |cookie|
			cookie.status += 1
		}
	end

	# assuming each batch is of the same cookie type, test 1st cookie
	def cookie
		@batch[0]
	end

	# signal when cookies are almost ready
	def signal?
		puts "Cookies are almost ready." if cookie.status? === :almost_ready
	end

	def remove_batch
		@batch = []
	end

	def pick_time
		puts "How many minutes will you bake?"
		gets.chomp.to_i
	end

	def new_batch?
		puts "Cook another batch? (y/n)"
		gets.chomp.downcase
	end

	# I'm thinking of this as the view in MVC
	# the baker inputs cookie tupe and bake time
	# then the model runs... is that right?
	def make_batch!
		create_batch!

		timer = pick_time

		while timer > 0
			bake!
			signal?
			timer -= 1
		end

		puts "You have baked #{@batch.size} #{cookie.status?} #{cookie.type} cookies."
		remove_batch

		make_batch! if new_batch? === 'y'
	end
end

class Cookie
	# we'll refer to cookie diameter as size for shorter code
	attr_reader :type, :size, :bake_times
	attr_accessor :status

	# we'll provide a default cookie size of 2 inches
	# which can be changed in cookie subclasses
	def initialize(type='', size=2, status=0)
		@type = type
		@size = size
		@status = status
		@bake_times = {
			0..12 => :doughy,
			13..14 => :almost_ready,
			15..20 => :ready,
			21..(1/0.0) => :burned
		}
	end

	def status?
		@bake_times.select { |time| time === @status }.values.first
	end
end

class ChocolateChip < Cookie
	attr_reader :chip_size, :num_chips

	def initialize(num_chips=8)
		super(type="chocolate chip", size=3, status=0)
		@num_chips = num_chips
		@bake_times = {
			0..17 => :doughy,
			18..19 => :almost_ready,
			20..25 => :ready,
			26..(1/0.0) => :burned
		}
	end
end

class Peanut < Cookie
	attr_reader :num_peanuts

	def initialize(num_peanuts=5)
		super(type="peanut", size=2, status=0)
		@num_peanuts = num_peanuts
		@bake_times = {
			0..8 => :doughy,
			9..10 => :almost_ready,
			11..15 => :ready,
			16..(1/0.0) => :burned
		}
	end
end

test = Oven.new
test.make_batch!
