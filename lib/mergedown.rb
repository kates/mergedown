require 'fileutils'

class Mergedown
  def initialize(src_dir, options={})
    @cache = {}
    @content = ""
    process(File.join(src_dir, options[:mainfile]))
    File.open(File.join(".", options[:outfile]), 'w') do |f|
      f.write @content
    end
  end

  def parse(txt)
    m = txt.scan /^:include\s+"([^\"]*)"/
    (m || []).flatten.uniq
  end

  def process(file_path, parents = [])
    parents << file_path if parents.length == 0

    if @cache[file_path]
      @content = @cache[file_path]
    else
      file = File.read(file_path)
      paths = parse file
      if paths.length > 0
        paths.each do |path|
          regex = Regexp.new("^\:include\\s+\"#{path}\".*$\n")
          if parents.include?(path)
            @content = ""
          else
            process(path, parents + [path])
          end
          file.gsub!(regex, @content)
        end
      end
      @content = file
      @cache[file_path] ||= file
    end
  end
end
