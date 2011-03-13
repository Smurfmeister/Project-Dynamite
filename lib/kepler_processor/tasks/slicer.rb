module KeplerProcessor
  class CLI
    desc 'slice', 'Slice file into multiple segments'
    common_method_options
    method_option :slice_size, :aliases => '-s', :type => :numeric, :required => true, :desc => 'Specify a slice size to use.'
    def slice
      clean_options
      Slicer.new(options).execute!
    end
  end

  class Slicer < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        super do
          slice
        end
      end

      private

        def slice
          # identify expected space between points, based on cadence
          std_range = @input_filename.split("_").last.split(".").first == "slc" ? 0.00068 : 0.02
          @slice_size = @options[:slice_size] / std_range

          # slice the input data array into arrays of size slice_size
          # for each slice, save a series of output files named according to position in time (eg. @input_filename_slice4).
          @slices = []
          @input_data.each_slice(@slice_size) { |slice| @slices << slice }
        end

        def output_filename
          # Determine the output filename from input_filename and slice properties
          @input_filename.dup.split("/").last.insert(-9, "_#{@options[:slice_size]}d-slices-part#{@slice_number}")
        end

        def save!
          @slices.each_with_index do |slice, i|
            @slice_number = i
            @output_data = slice
            super
          end
        end
    end
  end
end
