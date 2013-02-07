module KeplerProcessor
  module FourierTransformable

    attr_accessor :options

    def compute_amplitude_spectrum(source_data = nil)
      source_data ||= input_data
      time_span_of_dataset = source_data.last.first - source_data.first.first
      if @options[:fourier_range]
        start_frequency = @options[:fourier_range].split(",").first.to_f
        final_frequency = @options[:fourier_range].split(",").last.to_f
      else
        start_frequency = 0
        final_frequency = cadence == :slc ? 100 : 24
      end
      dft source_data.map { |x| x[0] }, source_data.map { |x| x[1] }, source_data.size, time_span_of_dataset, start_frequency, final_frequency
    end

    def cadence
      input_filename_without_extension.split("_")[3].to_sym
    end

    def peak_point(data)
      @sorted_amp = data.sort_by { |x| x[1] }
      @sorted_amp.last
    end

    def percentile_95(data)
      @binned_results = []
      @sorted_freq = data.sort_by { |x| x[0] }
      @slice_size = data.size / 25
      @sorted_freq.each_slice(@slice_size) do |slice|
        percentile = (slice.size * 0.95).round_to 0
        sorted_slice = slice.sort_by { |y| y[1] }
        this_result = sorted_slice[percentile]
        @binned_results << this_result.last unless this_result.nil? # sometimes last slice is small enough that this_result is nil
      end
      binned_sorted = @binned_results.sort
      median = (binned_sorted.size / 2) + 1 # dividing by int returns int, but rounded down. So add 1.
      binned_sorted[median]
    end

  end
end