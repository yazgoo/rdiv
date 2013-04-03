require 'rdiv.rb'
include Rdiv
class Enemy < Item
    def initialize x, dep_x, dep_y
        super x, -20
        @dep_x, @dep_y = dep_x, dep_y
        @scale = 0.5 * (1 + rand)
    end
    def run
        die do
            first_item(:Score).increment
            Explosion.new @x, @y
        end if collides :Shot
        die if @y > (@@height + @height)
        translate @dep_x, @dep_y
    end
end
class Explosion < AnimatedItem
end
class Score < Counter
    def initialize value
        super value, 0xffffffff, :center, 0
    end
end
class Shot < Item
    def run
        die if y < 0
        translate 0, -16
    end
end
class Ship < Item
    def initialize
        super
        @cannon_energy = 0
        @cannon_energy_maximum = 10
    end
    def run
        move_to @mouse.x, @@height - @height
        score = first_item(:Score)
        if @mouse.left and @cannon_energy == @cannon_energy_maximum and score > 0
            score.decrement
            Shot.new(@x, @y - @height / 2)
            @cannon_energy = 0
        end
        @cannon_energy += 1 if @cannon_energy < @cannon_energy_maximum
        die do
            Explosion.new @x, @y
            Text.new i18n :die
        end if collides :Enemy
    end
end
class Test1 < Main
    def setup
        Ship.new
        Score.new 10
    end
    def run
        if @done.nil?
            Enemy.new rand(0, @@height), rand(-1, 1), rand(1, 2) if rand(0, 1000) < 10
            if first_item(:Score) <= 0
                @done = Text.new i18n :no_more_amo
            elsif first_item(:Score) >= 15
                @done = Text.new i18n :win
            end
        end
    end
end
Test1.new.start
