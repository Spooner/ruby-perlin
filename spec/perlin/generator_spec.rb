
require File.expand_path("../../helper.rb", __FILE__)


describe Perlin::Generator do
  before :each do
    @classic = Perlin::Generator.new 123, 1.5, 2, :classic => true
    @simplex = Perlin::Generator.new 1, 1.5, 2
    @accuracy = 0.00001
  end

  it "should have seed set correctly" do
    expect(@classic.seed).to eq 123
    expect(@classic.seed).to be_kind_of Integer
  end

  it "should have seed set uniquely on all generators" do
    # This was a bug in the original code!
    g = Perlin::Generator.new 99, 1, 1
    expect(g.seed).to eq 99
    expect(g.seed).to be_kind_of Integer

    expect(@classic.seed).to eq 123
    expect(g[0, 0]).not_to eq @classic[0, 0]
  end

  it "should have persistence set correctly" do
    expect(@classic.persistence).to be_within(@accuracy).of 1.5
  end

  it "should have octave set correctly" do
    expect(@classic.octave).to eq 2
    expect(@classic.octave).to be_kind_of Integer
  end

  describe "SIMPLEX" do
    it "should have classic? set correctly" do
      expect(@simplex.classic?).to be false
    end
  end

  describe "CLASSIC" do
    it "should have classic? set correctly" do
      expect(@classic.classic?).to be true
    end
  end

  describe "seed=" do
    it "should set seed correctly" do
      @classic.seed = 12
      expect(@classic.seed).to eq 12
      expect(@classic.seed).to be_kind_of Integer
    end

    it "should fail unless >= 1" do
      expect { @classic.seed = 0 }.to raise_error ArgumentError, "seed must be >= 1"
    end
  end

  describe "persistence=" do
    it "should set persistence correctly" do
      @classic.persistence = 12.1513
      expect(@classic.persistence).to eq 12.1513
      expect(@classic.persistence).to be_kind_of Float
    end
  end

  describe "octave=" do
    it "should set octave correctly" do
      @classic.octave = 12
      expect(@classic.octave).to eq 12
      expect(@classic.octave).to be_kind_of Integer
    end

    it "should fail unless >= 1" do
      expect { @classic.octave = 0 }.to raise_error ArgumentError, "octave must be >= 1"
    end
  end

  describe "classic=" do
    it "should set classic? correctly" do
      @simplex.classic = true
      expect(@simplex.classic?).to be true
    end
  end

  describe "[]" do
    it "[x, y] should support float values" do
      expect(@simplex[0, 0]).not_to be_within(@accuracy).of @simplex[0.2, 0.2]
    end

    it "[x, y, z] should support float values" do
      expect(@simplex[0, 0, 0]).not_to be_within(@accuracy).of @simplex[0.2, 0.2, 0.2]
    end

    it "should fail if given too few arguments" do
      expect { @classic[0] }.to raise_error ArgumentError
    end

    it "should fail if given too many arguments" do
      expect { @classic[0, 0, 0, 0] }.to raise_error ArgumentError
    end

    context "SIMPLEX" do
      describe "[](x, y)" do
        it "should return the appropriate value" do
          expect(@simplex[0, 1]).to be_within(@accuracy).of -0.7169484162988542
        end

        it "should return different values based on seed" do
          initial = @simplex[9, 5]
          @simplex.seed = 95
          expect(initial).to_not be_within(@accuracy).of @simplex[9, 5]
        end
      end

      describe "[](x, y, z)" do
        it "should return the appropriate value" do
          expect(@simplex[0, 1, 2]).to be_within(@accuracy).of 0.3528568374548613
        end
      end
    end

    context "CLASSIC" do
      describe "[](x, y)" do
        it "should return the appropriate value" do
          expect(@classic[0, 0]).to be_within(@accuracy).of -1.0405873507261276
        end

        it "should return different values based on seed" do
          initial = @classic[9, 5]
          @classic.seed = 95
          expect(initial).to_not be_within(@accuracy).of @classic[9, 5]
        end
      end

      describe "[](x, y, z)" do
        it "should return the appropriate value" do
          expect(@classic[0, 0, 0]).to be_within(@accuracy).of -1.5681833028793335
        end
      end
    end
  end

  describe "chunk" do
    describe "chunk 2D" do

      context "SIMPLEX" do
        it "should return the appropriate values" do
          chunk = @simplex.chunk 1, 2, 3, 4, 1
          expected = [
            [0.3256153247344187, -0.044141564834959, -1.9775393411691766e-07, -0.30403976440429686],
            [0.0, 1.9775393411691766e-07, 0.0, -0.21674697868461495],
            [1.9775393411691766e-07, -0.23931307266021215, -0.7600996287015893, -5.93261818394248e-07],
          ]
          same_array_within_accuracy chunk, expected, @accuracy
        end

        it "should give the same results, regardless of x/y offset" do
          chunk1 = @simplex.chunk 0, 0, 3, 3, 0.1
          chunk2 = @simplex.chunk 0.1, 0.1, 3, 3, 0.1

          expect(chunk2[0][0]).to eq chunk1[1][1]
          expect(chunk2[0][1]).to eq chunk1[1][2]
          expect(chunk2[1][0]).to eq chunk1[2][1]
          expect(chunk2[1][1]).to eq chunk1[2][2]
        end

        it "should work with a block" do
          arr = []
          @simplex.chunk 1, 2, 3, 4, 1 do |h, x, y|
            arr << [h, x, y]
          end

          expected = [
            [0.3256153247344187, 1.0, 2.0],
            [-0.044141564834959, 1.0, 3.0],
            [-1.9775393411691766e-07, 1.0, 4.0],
            [-0.30403976440429686, 1.0, 5.0],
            [0.0, 2.0, 2.0],
            [1.9775393411691766e-07, 2.0, 3.0],
            [0.0, 2.0, 4.0],
            [-0.21674697868461495, 2.0, 5.0], 
            [1.9775393411691766e-07, 3.0, 2.0], 
            [-0.23931307266021215, 3.0, 3.0], 
            [-0.7600996287015893, 3.0, 4.0], 
            [-5.93261818394248e-07, 3.0, 5.0],
          ]
          same_array_within_accuracy arr, expected, @accuracy
        end
      end

      context "CLASSIC" do
        it "should return the appropriate values" do
          chunk = @classic.chunk 1, 2, 3, 4, 1
          expected = [
            [-2.014809340238571, -0.7094215080142021, -0.5946878045797348, 0.4915006756782532],
            [-1.4068767204880714, -0.732808068394661, 0.07362580299377441, -0.325466126203537],
            [-0.857817449606955, -1.940980076789856, -0.5687579363584518, 1.4209578335285187],
          ]
          same_array_within_accuracy chunk, expected, @accuracy
        end

        it "should give the same results, regardless of x/y offset" do
          chunk1 = @classic.chunk 0, 0, 3, 3, 0.1
          chunk2 = @classic.chunk 0.1, 0.1, 3, 3, 0.1
          expect(chunk2[0][0]).to eq chunk1[1][1]
          expect(chunk2[0][1]).to eq chunk1[1][2]
          expect(chunk2[1][0]).to eq chunk1[2][1]
          expect(chunk2[1][1]).to eq chunk1[2][2]
        end

        it "should work with a block" do
          arr = []
          @classic.chunk 1, 2, 3, 4, 1 do |h, x, y|
            arr << [h, x, y]
          end
          expected = [
            [-2.014809340238571, 1.0, 2.0],
            [-0.7094215080142021, 1.0, 3.0],
            [-0.5946878045797348, 1.0, 4.0],
            [0.4915006756782532, 1.0, 5.0], 
            [-1.4068767204880714, 2.0, 2.0], 
            [-0.732808068394661, 2.0, 3.0], 
            [0.07362580299377441, 2.0, 4.0], 
            [-0.325466126203537, 2.0, 5.0], 
            [-0.857817449606955, 3.0, 2.0], 
            [-1.940980076789856, 3.0, 3.0], 
            [-0.5687579363584518, 3.0, 4.0], 
            [1.4209578335285187, 3.0, 5.0],
          ]
          same_array_within_accuracy arr, expected, @accuracy
        end
      end

      it "should fail if given negative size_x" do
        expect { @classic.chunk 0, 0, -1, 0 }.to raise_error ArgumentError
      end

      it "should fail if given negative size_y" do
        expect { @classic.chunk 0, 0, 0, -1 }.to raise_error ArgumentError
      end
    end

    describe "chunk 3D" do
      context "SIMPLEX" do
        it "should return the appropriate values" do
          chunk = @simplex.chunk 6, 5, 4, 3, 2, 1, 1
          expected = [
            [ [-0.13219586780905937], [-0.10557871005195935], ],
            [ [0.057937057229464836], [0.14160177316516637] ],
            [ [0.4784122159704566], [0.23034484239760417] ],
          ]
          same_array_within_accuracy chunk, expected, @accuracy
        end

        it "should work with a block" do
          arr = []
          @simplex.chunk 6, 5, 4, 3, 2, 1, 1 do |h, x, y, z|
            arr << [h, x, y, z]
          end
          expected = [
            [-0.13219586780905937, 6.0, 5.0, 4.0],
            [-0.10557871005195935, 6.0, 6.0, 4.0],
            [0.057937057229464836, 7.0, 5.0, 4.0], 
            [0.14160177316516637, 7.0, 6.0, 4.0], 
            [0.4784122159704566, 8.0, 5.0, 4.0],
            [0.23034484239760417, 8.0, 6.0, 4.0],
          ]
          same_array_within_accuracy arr, expected, @accuracy
        end
      end

      context "CLASSIC" do
        it "should return the appropriate values" do
          chunk = @classic.chunk 6, 5, 4, 3, 2, 1, 1
          expected = [
            [[0.7522532045841217], [0.3314518630504608]],
            [[0.3198353797197342], [0.967293307185173]],
            [[1.1024393141269684], [0.5659154206514359]],
          ]
          same_array_within_accuracy chunk, expected, @accuracy
        end

        it "should work with a block" do
          arr = []
          @classic.chunk 6, 5, 4, 3, 2, 1, 1 do |h, x, y, z|
            arr << [h, x, y, z]
          end
          expected = [
            [0.7522532045841217, 6.0, 5.0, 4.0],
            [0.3314518630504608, 6.0, 6.0, 4.0],
            [0.3198353797197342, 7.0, 5.0, 4.0],
            [0.967293307185173, 7.0, 6.0, 4.0], 
            [1.1024393141269684, 8.0, 5.0, 4.0], 
            [0.5659154206514359, 8.0, 6.0, 4.0]]
          same_array_within_accuracy arr, expected, @accuracy
        end
      end

      it "should fail if given negative size_x" do
        expect { @classic.chunk 0, 0, 0, -1, 0, 0 }.to raise_error ArgumentError
      end

      it "should fail if given negative size_y" do
        expect { @classic.chunk 0, 0, 0, 0, -1, 0 }.to raise_error ArgumentError
      end

      it "should fail if given negative size_z" do
        expect { @classic.chunk 0, 0, 0, 0, 0, -1 }.to raise_error ArgumentError
      end
    end
  end
end