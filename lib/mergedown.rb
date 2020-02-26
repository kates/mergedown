require 'fileutils'

class Mergedown
  def initialize(src_dir, options={})
    @outfile = options[:outfile]
    File.delete(@outfile) if File.exist?(@outfile)
    process(src_dir, options[:mainfile])
  end

  def process(folder, filename)
    file_path = File.join(folder, filename)

    if filename !~ /\.md$/
      if File.exist?(File.join(file_path, 'main.md'))
        process(file_path, 'main.md')
      end
      return
    end

    File.foreach(file_path) do |line|
      if line =~ /^:include\s+"([^\"]*)"/
        process(folder, $1)
      else
        File.open(@outfile, "a") { |f| f.write line }
      end
    end
  end
end
