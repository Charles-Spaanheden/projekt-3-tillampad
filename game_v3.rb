require 'ruby2d'

# Set up window
set title: "Platformer Game", width: 800, height: 400

# Constants
GRAVITY = 0.5
JUMP_POWER = 10
MOVE_SPEED = 5
PLATFORM_WIDTH = 100
PLATFORM_HEIGHT = 20
PLATFORM_SPEED = 1

# Player class
class Player
  attr_reader :x, :y, :width, :height
  attr_accessor :jumping, :y_velocity

  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
    @x_velocity = 0
    @y_velocity = 0
    @jumping = false
    @jump_power = JUMP_POWER
  end

  def move_left
    @x_velocity = -MOVE_SPEED
  end

  def move_right
    @x_velocity = MOVE_SPEED
  end

  def stop_x_movement
    @x_velocity = 0
  end

  def jump
    if !@jumping
      @y_velocity = -@jump_power
      @jumping = true
    end
  end

  def update
    # Apply gravity
    @y_velocity += GRAVITY

    # Update position
    @x += @x_velocity
    @y += @y_velocity

    # Boundary checks
    @x = 0 if @x < 0
    @x = Window.width - @width if @x > Window.width - @width
    @y = 0 if @y < 0
    @y = Window.height - @height if @y > Window.height - @height

    # Reset jumping state if player is on the ground
    @jumping = false if @y >= Window.height - @height
  end

  def collides_with?(object)
    @x < object.x + object.width &&
      @x + @width > object.x &&
      @y < object.y + object.height &&
      @y + @height > object.y
  end

  # Setter method for the y attribute
  def y=(new_y)
    @y = new_y
  end

  # Check if player collides with object from below
  def collides_from_below?(object)
    @y_velocity >= 0 && @y + @height > object.y &&
      @y + @height - @y_velocity <= object.y &&
      @x + @width > object.x &&
      @x < object.x + object.width
  end
end

# Platform class
class Platform
  attr_reader :x, :y, :width, :height

  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
  end

  def update
    @y += PLATFORM_SPEED
  end

  def draw
    Rectangle.new(x: @x, y: @y, width: @width, height: @height, color: 'green')
  end
end

# Create player instance
player = Player.new(100, 100, 50, 50)

# Array to store platforms
platforms = []

# Event handling
on :key_down do |event|
  case event.key
  when 'a'
    player.move_left
  when 'd'
    player.move_right
  when 'w'
    player.jump
  end
end

on :key_up do |event|
  case event.key
  when 'a','d'
    player.stop_x_movement
  end
end


# Game loop
update do
  clear
  player.update

  # Draw player
  Image.new('player_cube.png', x: player.x, y: player.y, width: player.width, height: player.height,)

  # Add new platform randomly
  if rand(100) < 2
    platforms << Platform.new(rand(Window.width - PLATFORM_WIDTH), 0, PLATFORM_WIDTH, PLATFORM_HEIGHT)
  end

  # Collision detection with player
  platforms.each do |platform|
    platform.update
    platform.draw

    if player.collides_with?(platform)
      # If player is moving downward and collides with the platform from above, adjust position
      if player.y_velocity > 0 && player.y + player.height > platform.y && player.y < platform.y + platform.height
        player.y = platform.y - player.height
        player.y_velocity = 0
        player.jumping = false
      # If player is moving upward and collides with the platform from below, adjust position
      #elsif player.collides_from_below?(platform)
       # player.y = platform.y + platform.height
        #player.y_velocity = 0
      end
    end
    end

  # Remove platforms that are out of screen
  platforms.reject! { |platform| platform.y > Window.height }
end



show
