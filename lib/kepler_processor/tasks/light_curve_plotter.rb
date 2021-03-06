module KeplerProcessor
  class LightCurvePlotter < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        super do
          plot
        end
      end

      private

        def plot
          ::Gnuplot.open do |gp|
            ::Gnuplot::Plot.new(gp) do |plot|
              plot.terminal "png size 900,300"
              # plot.format 'y "%6.1f"'
              plot.lmargin "10"
              plot.output "#{@options[:output_path]}/#{@input_filename_without_extension}_plot.png"
              plot.ylabel "Delta Kp (mmag)"
              plot.xlabel "BJD - 2400000"
              plot.yrange "[] reverse"

              x = @input_data.map { |point| point[0] }
              y = @input_data.map { |point| point[1] * 1000 }

              plot.data << ::Gnuplot::DataSet.new([x, y]) do |ds|
                ds.with = "lines"
                ds.notitle
              end
            end
          end
        end
    end
  end
end