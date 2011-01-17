module KeplerProcessor
  class Computor < Base

    def run
      super do
        dft
      end
    end

    def dft
      dataset_length = @input_data.last[0] - @input_data.first[0]   # gives length of dataset in days by difference in final and initial time
      frequency_step = 1 / (10.0 * dataset_length)                  # step is 1/10T
      frequencies = (0..100).in_steps_of frequency_step

      @output_data = {}
      @input_data.each do |line| # |line| is representing 'i' - more intuitive and ruby-like
        time = line[0]
        magnitude = line[1]
        frequencies.each do |f|
          cos_i = Math.cos(2 * Math::PI * f * time)
          sin_i = Math.sin(2 * Math::PI * f * time)

          real_component = cos_i * magnitude           # the sum of all the cosine terms times the magnitudes
          imaginary_component = sin_i * magnitude

          # Amplitude calculated using product rather than ^2 in the hope of saving computing time
          amp_j = 2 * Math.sqrt(real_component * real_component + imaginary_component * imaginary_component) / @input_data.size
          phi_j = (Math.atan(-imaginary_component / real_component)) ** 2

          # Output data is a hash of frequency-complex number pairs, with a new line for each frequency step.
          @output_data[f] = Complex(0,0) unless @output_data.has_key?(f)
          @output_data[f] += Complex(amp_j, phi_j)
        end
      end
      puts @output_data.inspect
    end

  end
end
