require 'rdiv.rb'
module Rdiv
    class Enemy < Process
        def initialize x, dep_x, dep_y
            super x, -20
            @dep_x = dep_x; @dep_y = dep_y
            size rand(25, 100)
        end
        def run
            die { } if @y > 220 or collides :Shot
            @x = @x + @dep_x
            @y = @y + @dep_y
            frame
        end
    end
    class Shot < Process
        def run
            die {} if y < 0
            @y = @y - 16
            frame
        end
    end
    class Ship < Process
        def initialize
            super 160, 180
        end
        def run
            @x = @mouse.x
            Shot.new(@x, @y - 20) if @mouse.left
            quit "You died. Thank's for playing to test1." if collides :Enemy
            frame
        end
    end
    class Test1 < Program
        def initialize
            super 320, 200
            put_screen :background
            Ship.new
        end
        def run
            Enemy.new rand(0, 320), rand(-1, 1), rand(1, 2) if rand(0, 100) < 3
        end
    end
    Test1.new().start
end
