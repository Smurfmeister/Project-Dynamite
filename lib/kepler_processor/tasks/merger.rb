module KeplerProcessor

  class CLI
    desc 'merge', 'Merge multiple files together'
    common_method_options
    method_option :merge_ratio, :aliases => '-m', :type => :numeric, :required => true, :desc => 'Specify a merge ratio to use.'
    def merge
      clean_options
      Merger.new(options).execute!
    end
  end

  class Merger < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        super do
          merge!
        end
      end

      private

        def merge!
          # the gap between consecutive points it time for slc data is just over 0.00068 and for llc data is just greater than 0.02
          # therefore, if the data is slc, as indicated by input_filename, take the first value for std_range, if not, take second.
          std_range = @input_filename.split("_")[3] == "slc" ? 0.00068 : 0.02

          # slice the input data array into arrays of size merge_ratio
          # for each slice, replace the slice by the arithmetic mean value, unless there is a time gap in the data greater than the std gap or <10 items in slice (eof).
          @output_data = []
          @input_data.each_slice(@options[:merge_ratio]) do |slice|
            if ( slice.last[0] - slice.first[0] ) > ( @options[:merge_ratio] * std_range ) || slice.size < @options[:merge_ratio]
              slice.each { |s| @output_data << s } # Don't average things out
            else
              @output_data << [slice.map { |e| e[0] }.inject(:+).to_f / @options[:merge_ratio], slice.map { |e| e[1] }.inject(:+).to_f / @options[:merge_ratio]]
            end
          end
        end

        def output_filename
          # Determine the output filename from header
          @input_filename.dup.split("/").last.insert(-9, "_#{@options[:merge_ratio]}to1")
        end
    end
  end
end
