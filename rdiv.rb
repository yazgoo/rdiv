require 'frontend'
module Rdiv
    class Utils
        def set_new_process _proc
            @@on_new_process = _proc
        end
        def set_get_process _proc
            @@get_process = _proc
        end
        def set_get_processes _proc
            @@get_processes = _proc
        end
        def quit message
            puts message
            exit
        end
        def get_image_path name
            "./test1/img/#{name.to_s}.png"
        end
        def rand a, b
            a + Kernel.rand(b - a)
        end
        class Mouse
            attr_accessor :x, :y, :left, :right
        end
        @@mouse = Mouse.new
        def initialize
            @mouse = @@mouse
        end
    end
    class Process < Utils
        attr_accessor :x, :y, :dead, :f, :name, :width, :height
        attr_reader :dead
        def size value
        end
        def die
            yield
            @dead = true
        end
        def frame f = 100
            @f = 100
        end
        def deframe f = 100
            @f -= 100
        end
        def needs_computing?
            @f = 0 if @f.nil?
            @f < 100
        end
        def abs a
            a = a < 0 ? -a : a
        end
        def collides what
            @@get_process.call(what.to_s).each do |process|
                if process != self
                    if x < process.x
                        if (process.x - x) < width
                            if y < process.y
                                # self 
                                #      process
                                return true if (process.y - y) < height
                            else
                                #      process
                                # self
                                return true if (y - process.y) < process.height
                            end
                        end
                    else
                        if (x - process.x) < process.width
                            if y < process.y
                                #         self
                                # process
                                return true  if (process.y - y) < height
                            else
                                # process
                                #         self
                                return true if (y - process.y) < process.height
                            end
                        end
                    end
                    return true if abs(x - process.x) < 10 and abs(y - process.y) < 10
                end
            end
            return false
        end
        def leave_me_alone
            @@get_processes.call.each do |process|
                process.die {} if process != self
            end
        end
        def get_image_path
            super(@name[0, 1].downcase + @name[1..-1])
        end
        def initialize x, y
            super()
            @x = x; @y = y
            @name = self.class.name.split('::').last
            @@on_new_process.call self
        end
    end
    class Program < Utils
        def initialize width, height
            @frontend = Frontend.new width, height
            set_new_process(Proc.new { |p| @frontend.push_process(p) })
            set_get_process(Proc.new do |name|
                result = []
                @frontend.processes.keys.each do |process|
                    result.push process if process.name == name
                end
            end)
            set_get_processes(Proc.new { @frontend.processes.keys })
        end
        def put_screen name
            @frontend.set_background_image get_image_path(name)
        end
        def start
            @frontend.run(Proc.new do 
                @frontend.set_mouse @@mouse
                run
                processes = @frontend.processes.keys
                processes.each do |process|
                    process.run while process.needs_computing?
                    process.deframe
                    @frontend.delete_process process if process.dead
                end
            end)
        end
    end
end
