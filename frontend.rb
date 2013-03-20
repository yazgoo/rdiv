require 'rubygems'
require 'gosu'
class Frontend < Gosu::Window
    attr_accessor :processes
    def initialize width, height
        super width, height, false
        self.caption = "Rdiv"
        @processes = {}
        @mouse_down = false
    end
    def set_background_image path
        @background_image = Gosu::Image.new(self, path, true)
    end
    def push_process process
        @processes[process] = Gosu::Image.new(self, process.get_image_path(), true)
        process.width = @processes[process].width
        process.height = @processes[process].height
    end
    def delete_process process
        @processes.delete process
    end
    def button_down(id)
        case id
        when Gosu::MsLeft
            @mouse_down = true
        end
    end
    def button_up(id)
        case id
        when Gosu::MsLeft
            @mouse_down = false
        end
    end
    def set_mouse mouse
        mouse.x = mouse_x
        mouse.y = mouse_y
        mouse.left = @mouse_down
    end
    def draw
        @background_image.draw(0, 0, 0) if not @background_image.nil?
        @processes.each do |process, image|
            image.draw_rot(process.x, process.y, 1, 0)
        end
    end
    def update
        @_proc.call if not @_proc.nil?
    end
    def run _proc
        @_proc = _proc
        show
    end
end

