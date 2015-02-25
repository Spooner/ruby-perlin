require 'rubygems'
require 'texplay'
require 'fidgit'
require 'perlin'

include Gosu

class Visualizer < Chingu::Window
  def initialize
    super 800, 600, false, 0.1
    self.caption = "Perlin Visualizer"
    enable_undocumented_retrofication
    push_game_state Visualize
  end
end

class Visualize < Fidgit::GuiState
  SLIDER_WIDTH = 180
  IMAGE_WIDTH = 74
  IMAGE_SCALE = 8

  def initialize
    super

    @image = TexPlay.create_image $window, IMAGE_WIDTH, IMAGE_WIDTH, :color => :red
    @noise = Perlin::Generator.new 1, 0, 1

    horizontal do
      image_frame @image, :factor => IMAGE_SCALE

      vertical do
        vertical do
          @seed_label = label ""
          @seed_slider = slider :range => 1..10000, :width => SLIDER_WIDTH, :tip => "Perlin::Generator#seed" do |_, value|
            @seed_label.text = "Seed = #{value}"
            @noise.seed = value
            update_image
          end
        end

        vertical do
          @persistence_label = label ""
          @persistence_slider = slider :range => 0.0..1.0, :width => SLIDER_WIDTH, :tip => "Perlin::Generator#persistence" do |_, value|
            @persistence_label.text = "Persist = #{"%.2f" % value}"
            @noise.persistence = value
            update_image
          end
        end

        vertical do
          @octave_label = label ""
          @octave_slider = slider :range => 1..10, :width => SLIDER_WIDTH, :tip => "Perlin::Generator#octave" do |_, value|
            @octave_label.text = "Octave = #{value}"
            @noise.octave = value
            update_image
          end
        end

        vertical :padding_top => 32 do
          @classic_button = toggle_button "Classic noise?" do |_, value|
            @noise.classic = value
            update_image
          end
        end

        vertical :padding_top => 64 do
          @step_label = label ""
          @step_slider = slider :range => 0.01..1.0, :width => SLIDER_WIDTH, value: 0.1, :tip => "Step between points (pixels) in chunk" do |_, value|
            @step_label.text = "Step = #{"%.2f" % value}"
            @width_label.text = "Width = #{"%.2f" % (value * IMAGE_WIDTH)}"
            update_image
          end

          @width_label = label "", :tip => "Width of visualized area in window"
        end

        # Initial values, so we get the correct details.
        @seed_slider.value = 0
        @persistence_slider.value = 0
        @octave_slider.value = 0
        @step_slider.value = 0.1
      end
    end

    update_image
  end

  def update_image
    step = @step_slider.value
    width = @image.width

    @noise.chunk 0, 0, width, width, step do |n, x, y|
      intensity = (n + 1) * 0.5
      @image.set_pixel x.fdiv(step).round, y.fdiv(step).round, :color => [intensity, intensity, intensity], :sync_mode => :no_sync
    end

    @image.force_sync [0, 0, width, width]
  end
end

Visualizer.new.show