require 'frontend'
require 'yaml'
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
        def get_animation_path name
            "./test1/img/#{name.to_s}.ani"
        end
        def get_sound_path name
            "./test1/sound/#{name.to_s}.wav"
        end
        def get_i18n_path
            "./test1/i18n"
        end
        def rand a = nil, b = nil
            if a.nil? or b.nil?
                Kernel.rand
            else
                a + Kernel.rand(1 + b - a)
            end
        end
        class Mouse
            attr_accessor :x, :y, :left, :right
        end
        @@mouse = Mouse.new
        @@width = @@height = 0
        @@i18n_data = nil
        def i18n name
            @@i18n_data = YAML.load_file(get_i18n_path) if @@i18n_data.nil?
            result = @@i18n_data['en'][name.to_s]
        end
        def initialize
            @mouse = @@mouse
        end
        def each_item what
            @@get_process.call(what.to_s).each do |process| yield process end
        end
        def first_item what
            @@get_process.call(what.to_s).each do |process| return process end
            return nil
        end
    end
    class Item < Utils
        attr_accessor :x, :y, :dead, :f, :name, :width, :height, :scale
        attr_reader :dead, :animated, :n_x, :n_y, :i, :text
        def die &block
            block.call if block
            @dead = true
        end
        def translate dep_x, dep_y
            @x = @x + dep_x
            @y = @y + dep_y
        end
        def move_to x, y
            @x = x
            @y = y
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
        def uncapitalized_name
            @name = self.class.name.split('::').last if @name.nil?
            @name[0, 1].downcase + @name[1..-1]
        end
        def get_image_path
            super(uncapitalized_name)
        end
        def get_animation_path
            super(uncapitalized_name)
        end
        def get_sound_path
            super(uncapitalized_name)
        end
        def initialize x = 0, y = 0
            super()
            @scale = 1
            x = (@@width / 2) if x == :center
            y = @@height / 2 if y == :center
            @x = x; @y = y
            @@on_new_process.call self
        end
        def start_animation n_x, n_y
            @i = 0
            @n_x, @n_y, @n = n_x, n_y
        end
        def animation_stoped
            @animated = true
            return true if @i >= (@n_y * @n_x - 1)
            @i += 1
            false
        end
    end
    class Main < Utils
        def initialize width = 800, height = 600
            @@width = width
            @@height = height
            @frontend = Frontend.new width, height
            set_new_process(Proc.new { |p| @frontend.push_process(p) })
            set_get_process(Proc.new do |name|
                result = []
                @frontend.processes.keys.each do |process|
                    result.push process if process.name == name
                end
                result
            end)
            set_get_processes(Proc.new { @frontend.processes.keys })
            put_screen :background
            setup
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
                    process.run
                    @frontend.delete_process process if process.dead
                end
            end)
        end
        def setup
        end
    end
    class AnimatedItem < Item 
        def initialize x, y
            @animated = true
            ani = YAML.load_file(get_animation_path)
            start_animation ani['cols'].to_i, ani['rows'].to_i
            super x, y
        end
        def run
            die if animation_stoped
        end
    end
    class Text < Item
        attr_reader :color
        def initialize text, color = 0xff000000, x = :center, y = :center
            @text = text
            @color = color
            super x, y
        end
        def run
        end
    end
    class Counter < Text
        def initialize value, color = 0xff000000, x = :center, y = :center
            super value.to_s, color, x, y
        end
        def increment
            @text = (@text.to_i + 1).to_s
        end
        def decrement
            @text = (@text.to_i - 1).to_s
        end
        def > (i)
            @text.to_i > i
        end
        def >= (i)
            @text.to_i >= i
        end
        def <= (i)
            @text.to_i <= i
        end
    end
end
