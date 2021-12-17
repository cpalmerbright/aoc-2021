require 'byebug'
class Probe
  def initialize(min_x, max_x, min_y, max_y)
    @target_x = [min_x, max_x]
    @target_y = [min_y, max_y]
    @overall_max_y = 0
    @velocities = []
  end

  def fire
    max_x = [@target_x[0].abs, @target_x[1].abs].max
    max_y = [@target_y[0].abs, @target_y[1].abs].max

    (-max_x..max_x).to_a.each do |x|
      (-max_y..max_y).to_a.each do |y|
        fire_probe(x, y)
      end
    end

    p @overall_max_y
    p @velocities.length
  end

  def fire_probe(vx, vy)
    @in_range = false
    @x = 0
    @y = 0
    @step = 0

    @max_y = @y
    while !@in_range && @y >= @target_y.min && @x <= @target_x.max
      @step += 1
      @x += change_in_x(vx, @step)
      @y += change_in_y(vy, @step)
      @max_y = [@max_y, @y].max
      @velocities << [vx, vy] if in_target
      @overall_max_y = [@overall_max_y, @max_y].max if in_target

    end
    p [@step, @x, @y, @max_y, in_target]
  end

  def change_in_x(initial_x, step)
    if initial_x.positive?
      [initial_x - (step - 1), 0].max
    else
      [initial_x + (step - 1), 0].min
    end
  end

  def change_in_y(initial_y, step)
    initial_y - (step - 1)
  end

  def in_target
    @in_range = true if @x >= @target_x.min && @x <= @target_x.max && @y >= @target_y.min && @y <= @target_y.max
    @in_range
  end
end

Probe.new(179, 201,-109, -63).fire

