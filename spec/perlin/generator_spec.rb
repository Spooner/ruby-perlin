
require File.expand_path("../../helper.rb", __FILE__)

describe Perlin::Generator do
  before :each do
    @classic = Perlin::Generator.new 123, 1.5, 2, :classic => true
    @simplex = Perlin::Generator.new 1, 1.5, 2
    @accuracy = 0.00001
  end

  it "should have seed set correctly" do
    @classic.seed.should eq 123
    @classic.seed.should be_kind_of Integer
  end

  it "should have seed set uniquely on all generators" do
    # This was a bug in the original code!
    g = Perlin::Generator.new 99, 1, 1
    g.seed.should eq 99
    g.seed.should be_kind_of Integer

    @classic.seed.should eq 123
    g[0, 0].should_not eq @classic[0, 0]
  end

  it "should have persistence set correctly" do
    @classic.persistence.should be_within(@accuracy).of 1.5
  end

  it "should have octave set correctly" do
    @classic.octave.should eq 2
    @classic.octave.should be_kind_of Integer
  end

  describe "SIMPLEX" do
    it "should have classic? set correctly" do
      @simplex.classic?.should be_false
    end
  end

  describe "CLASSIC" do
    it "should have classic? set correctly" do
      @classic.classic?.should be_true
    end
  end

  describe "seed=" do
    it "should set seed correctly" do
      @classic.seed = 12
      @classic.seed.should eq 12
      @classic.seed.should be_kind_of Integer
    end

    it "should fail unless >= 1" do
      lambda { @classic.seed = 0 }.should raise_error ArgumentError, "seed must be >= 1"
    end
  end

  describe "persistence=" do
    it "should set persistence correctly" do
      @classic.persistence = 12.1513
      @classic.persistence.should eq 12.1513
      @classic.persistence.should be_kind_of Float
    end
  end

  describe "octave=" do
    it "should set octave correctly" do
      @classic.octave = 12
      @classic.octave.should eq 12
      @classic.octave.should be_kind_of Integer
    end

    it "should fail unless >= 1" do
      lambda { @classic.octave = 0 }.should raise_error ArgumentError, "octave must be >= 1"
    end
  end

  describe "classic=" do
    it "should set classic? correctly" do
      @simplex.classic = true
      @simplex.classic?.should be_true
    end
  end

  describe "[]" do
    it "[x, y] should support float values" do
      @simplex[0, 0].should_not be_within(@accuracy).of @simplex[0.2, 0.2]
    end



    it "[x, y, z] should support float values" do
      @simplex[0, 0, 0].should_not be_within(@accuracy).of @simplex[0.2, 0.2, 0.2]
    end

    it "should fail if given too few arguments" do
      lambda { @classic[0] }.should raise_error ArgumentError
    end

    it "should fail if given too many arguments" do
      lambda { @classic[0, 0, 0, 0] }.should raise_error ArgumentError
    end

    describe "SIMPLEX" do
      describe "[](x, y)" do
        it "should return the appropriate value" do
          @simplex[0, 1].should be_within(@accuracy).of 0.05811442311404391
        end

        it "should return different values based on seed" do
          initial = @simplex[9, 5]
          @simplex.seed = 95
          initial.should_not be_within(@accuracy).of @simplex[9, 5]
        end
      end

      describe "[](x, y, z)" do
        it "should return the appropriate value" do
          @simplex[0, 1, 2].should be_within(@accuracy).of 0.1565117670752736
        end
      end
    end

    describe "CLASSIC" do
      describe "[](x, y)" do
        it "should return the appropriate value" do
          @classic[0, 0].should be_within(@accuracy).of -1.0405873507261276
        end

        it "should return different values based on seed" do
          initial = @classic[9, 5]
          @classic.seed = 95
          initial.should_not be_within(@accuracy).of @classic[9, 5]
        end
      end

      describe "[](x, y, z)" do
        it "should return the appropriate value" do
          @classic[0, 0, 0].should be_within(@accuracy).of -1.5681833028793335
        end
      end
    end
  end

  describe "chunk" do
    describe "chunk 2D" do

      describe "SIMPLEX" do
        it "should return the appropriate values" do
          chunk = @simplex.chunk 1, 2, 3, 4, 1
          chunk.should eq [[0.5571850916535853, 0.3451618167752869, 0.016862032963892177, -0.013647447995516454], [0.05558941997362205, -0.023516295066696464, -0.18474763936940472, -0.269085274143078], [-0.1945774374435509, -0.40013138603862897, -0.3741884587955759, -0.1998954436836]]
        end

        it "should give the same results, regardless of x/y offset" do
          chunk1 = @simplex.chunk 0, 0, 3, 3, 0.1
          chunk2 = @simplex.chunk 0.1, 0.1, 3, 3, 0.1

          chunk2[0][0].should eq chunk1[1][1]
          chunk2[0][1].should eq chunk1[1][2]
          chunk2[1][0].should eq chunk1[2][1]
          chunk2[1][1].should eq chunk1[2][2]
        end

        it "should work with a block" do
          arr = []
          @simplex.chunk 1, 2, 3, 4, 1 do |h, x, y|
            arr << [h, x, y]
          end
          arr.should eq [[0.5571850916535853, 1.0, 2.0], [0.3451618167752869, 1.0, 3.0], [0.016862032963892177, 1.0, 4.0], [-0.013647447995516454, 1.0, 5.0], [0.05558941997362205, 2.0, 2.0], [-0.023516295066696464, 2.0, 3.0], [-0.18474763936940472, 2.0, 4.0], [-0.269085274143078, 2.0, 5.0], [-0.1945774374435509, 3.0, 2.0], [-0.40013138603862897, 3.0, 3.0], [-0.3741884587955759, 3.0, 4.0], [-0.1998954436836, 3.0, 5.0]]
        end
      end

      describe "CLASSIC" do
        it "should return the appropriate values" do
          chunk = @classic.chunk 1, 2, 3, 4, 1
          chunk.should eq [[-2.014809340238571, -0.7094215080142021, -0.5946878045797348, 0.4915006756782532], [-1.4068767204880714, -0.732808068394661, 0.07362580299377441, -0.325466126203537], [-0.857817449606955, -1.940980076789856, -0.5687579363584518, 1.4209578335285187]]
        end

        it "should give the same results, regardless of x/y offset" do
          chunk1 = @classic.chunk 0, 0, 3, 3, 0.1
          chunk2 = @classic.chunk 0.1, 0.1, 3, 3, 0.1
          chunk2[0][0].should eq chunk1[1][1]
          chunk2[0][1].should eq chunk1[1][2]
          chunk2[1][0].should eq chunk1[2][1]
          chunk2[1][1].should eq chunk1[2][2]
        end

        it "should work with a block" do
          arr = []
          @classic.chunk 1, 2, 3, 4, 1 do |h, x, y|
            arr << [h, x, y]
          end
          arr.should eq [[-2.014809340238571, 1.0, 2.0], [-0.7094215080142021, 1.0, 3.0], [-0.5946878045797348, 1.0, 4.0], [0.4915006756782532, 1.0, 5.0], [-1.4068767204880714, 2.0, 2.0], [-0.732808068394661, 2.0, 3.0], [0.07362580299377441, 2.0, 4.0], [-0.325466126203537, 2.0, 5.0], [-0.857817449606955, 3.0, 2.0], [-1.940980076789856, 3.0, 3.0], [-0.5687579363584518, 3.0, 4.0], [1.4209578335285187, 3.0, 5.0]]
        end
      end

      it "should fail if given negative size_x" do
        lambda { @classic.chunk 0, 0, -1, 0 }.should raise_error ArgumentError
      end

      it "should fail if given negative size_y" do
        lambda { @classic.chunk 0, 0, 0, -1 }.should raise_error ArgumentError
      end

    end

    describe "chunk 3D" do
      describe "SIMPLEX" do
        it "should return the appropriate values" do
          chunk = @simplex.chunk 6, 5, 4, 3, 2, 1, 1
          chunk.should eq [[[0.24743621515465233], [-0.3257963616110915]], [[-0.3311894469198845], [-0.26808402993439934]], [[-0.03463088940674653], [0.5211535687819419]]]

        end

        it "should work with a block" do
          arr = []
          @simplex.chunk 6, 5, 4, 3, 2, 1, 1 do |h, x, y, z|
            arr << [h, x, y, z]
          end
          arr.should eq [[0.24743621515465233, 6.0, 5.0, 4.0], [-0.3257963616110915, 6.0, 6.0, 4.0], [-0.3311894469198845, 7.0, 5.0, 4.0], [-0.26808402993439934, 7.0, 6.0, 4.0], [-0.03463088940674653, 8.0, 5.0, 4.0], [0.5211535687819419, 8.0, 6.0, 4.0]]
        end
      end

      describe "CLASSIC" do
        it "should return the appropriate values" do
          chunk = @classic.chunk 6, 5, 4, 3, 2, 1, 1
          chunk.should eq [[[0.7522532045841217], [0.3314518630504608]], [[0.3198353797197342], [0.967293307185173]], [[1.1024393141269684], [0.5659154206514359]]]
        end

        it "should work with a block" do
          arr = []
          @classic.chunk 6, 5, 4, 3, 2, 1, 1 do |h, x, y, z|
            arr << [h, x, y, z]
          end
          arr.should eq [[0.7522532045841217, 6.0, 5.0, 4.0], [0.3314518630504608, 6.0, 6.0, 4.0], [0.3198353797197342, 7.0, 5.0, 4.0], [0.967293307185173, 7.0, 6.0, 4.0], [1.1024393141269684, 8.0, 5.0, 4.0], [0.5659154206514359, 8.0, 6.0, 4.0]]
        end
      end

      it "should fail if given negative size_x" do
        lambda { @classic.chunk 0, 0, 0, -1, 0, 0 }.should raise_error ArgumentError
      end

      it "should fail if given negative size_y" do
        lambda { @classic.chunk 0, 0, 0, 0, -1, 0 }.should raise_error ArgumentError
      end

      it "should fail if given negative size_z" do
        lambda { @classic.chunk 0, 0, 0, 0, 0, -1 }.should raise_error ArgumentError
      end
    end

  end
end