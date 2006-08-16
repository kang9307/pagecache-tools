#!/usr/bin/ruby -w

require 'fstab'

FILECACHE = '/proc/filecache'
FSTAB = '/etc/mtab'
FMODE = File::CREAT | File::TRUNC | File::RDWR

class CachedFile

  attr_reader :dev, :file, :pages, :seq, :ino, :size, :cached, :percent, :state, :refcnt

  attr_writer :ino, :size, :cached, :percent, :state, :refcnt

  def initialize(file, dev, seq) 
    @file       = file
    @dev        = dev
    @seq        = seq
    @pages      = Array.new
  end

  def add(idx, len = 1)
    for i in 0...len
      @pages << idx+i
    end
    self
  end

  def complete
    if not empty?
      stat     = File.lstat(@file)
      @ino     = stat.ino 
      @size    = (stat.size + 1023) / 1024
      @cached  = 4 * @pages.size    # Fix me: pagesize=4k ?
      if @size > 0
        @percent = (@cached.to_f / @size).to_i
				@percent = 100 if @percent > 100
      else
        @percent = 0
      end
      @state   = "--"
      @refcnt  = 0
    end
  end

  def empty?
    !FileTest.exist?(@file) or (@seq != 0 and @pages.empty?)
  end

  def union(cfile)
    @pages.concat cfile.pages
    @pages.uniq!
    self
  end
  alias + union

  def intersection(cfile)
    @pages.delete_if do |page|
      !cfile.pages.include?(page)
    end
    self
  end
  alias & intersection

  def difference(cfile)
    @pages.delete_if do |page|
      cfile.pages.include?(page)
    end
    self
  end
  alias - difference

  def page_ranges 
    list = []
    idx = 0;
    len = 0;

    pages.sort!
    pages.each do |page|
      if idx + len == page
        len = len + 1
      else
        if len > 0
          list << [idx, len]
        end
        idx = page
        len = 1
      end
    end

    if len > 0
      list << [idx, len]
    end

    list
  end

  def to_s
    list = page_ranges

    s = "#{file}\n"
    list.each do |page|
      s = s + "#{page[0]}\t#{page[1]}\n"
    end
    s = s + "\n"

  end

end

class CachedFileList

  @@fstab = FSTab.new FSTAB

  def initialize
    @cfiles = Hash.new
  end

  def union(cfl)
    cfl.each do |cfile|
      cf = @cfiles[cfile.file]
      if cf == nil
        @cfiles[cfile.file] = cfile
      else
        cf.union cfile
      end
    end
    self
  end
  alias + union

  def intersection(cfl)
    @cfiles.each_value do |cfile|
      cf = cfl[cfile.file]
      if cf == nil
        @cfiles.delete cfile.file
      else
        cfile.intersection cf
      end
    end
    @cfiles.delete_if do |key, cfile| cfile.empty? end
    self
  end
  alias & intersection

  def difference(cfl)
    @cfiles.each_value do |cfile|
      cf = cfl[cfile.file]
      if cf != nil
        cfile.difference cf 
      end
    end
    @cfiles.delete_if do |key, cfile| cfile.empty? end
    self
  end
  alias - difference

  def each
    @cfiles.each_value do |cfile| 
        yield cfile
    end
    self
  end

  def [](file)
    @cfiles[file]
  end

  def delete(file)
    @cfiles.delete file
    self
  end

  def delete_if
    @cfiles.delete_if do |key, cfile|
      yield(cfile)
    end
    self
  end

  def CachedFileList.restore(input)
    cfl = CachedFileList.new
    if input == nil or input.empty?
      cfl.snapshot do |idx,len,|
        len > 0
      end
    else
      if File.stat(input).file?
        cfl.restore_from_file input 
      else
        cfl.restore_from_dir input 
      end
    end
    cfl
  end

  # Take a snapshot of /proc/filecache.
  def snapshot 
    File.open(FILECACHE, File::RDWR) do |filecache| 

      filecache.syswrite("private session")
      # filecache.syswrite("PRIVATE")
      read_filecache_index filecache

      @cfiles.each_value do |cfile|

        begin
          filecache.rewind
          filecache.syswrite(cfile.file)
          filecache.each_line do |line|
            idx, len, state, refcnt = line.split
            idx, len, refcnt = idx.to_i, len.to_i, refcnt.to_i
            if yield(idx, len, state, refcnt) then
              cfile.add idx, len
            end
          end
        rescue => err
          # $stderr.puts "#{err.backtrace.join("\n")}:", "\t#{err} - #{cfile.file}\n\n"
          $stderr.puts "#{err} - #{cfile.file}\n\n"
        end

      end

    end # File.open

    @cfiles.delete_if do |key, cfile| cfile.empty? end

    self
  end

  # get the cached file list from /proc/filecache.
  def read_filecache_index(filecache)
    seq = 1;
    begin
      filecache.rewind
      filecache.syswrite("index")
      filecache.each_line do |line|

        next if line[0] == ?# 

        line.gsub! '\011', "\011"  # ht
        line.gsub! '\012', "\012"  # nl
        line.gsub! '\040', "\040"  # sp
        line.gsub! '\\',   "\\"    # \

        ino, size, cached, cachedp, state, 
          refcnt, dev, file = line.split

        next if file == '(noname)'
        next if file =~ /\(deleted\)$/

        dev = "0x#{dev[0,5].delete(':')}".hex 

        if file =~ /\([0-9a-f]{2}:[0-9a-f]{2}\)/ then
          dev  = file.delete('(:)').hex
          fs   = @@fstab[dev]
          next if fs == nil
          file = fs.device_file
          cfile = CachedFile.new file, dev, 0 
        else
          fs = @@fstab[dev]
          next if fs == nil
          if fs.mount_point != "/" then
            file = fs.mount_point + file 
          end
          cfile = CachedFile.new file, dev, seq 
          seq = seq + 1;
        end


        cfile.ino     = ino.to_i
        cfile.size    = size.to_i
        cfile.cached  = cached.to_i 
        cfile.percent = cachedp.to_i
        cfile.state   = state
        cfile.refcnt  = refcnt.to_i

        @cfiles[file] = cfile 

      end
    rescue => err
      $stderr.puts "#{err.backtrace.join("\n")}:", "#{err}\n\n"
    end
  end

  # Restore the pre-saved snapshot of /proc/filecache from the files under 'dir'.
  def restore_from_dir(dir)
    begin
      Dir.foreach(dir) do |file|
        file = "#{dir}/#{file}"
        next if not File.lstat(file).file?
        seq = loadfile file
      end
    rescue => err
      $stderr.puts "#{err.backtrace.join("\n")}:", "#{err}\n\n"
    end
    @cfiles.delete_if do |key, cfile| cfile.empty? end
  end

  # Restore one partion's pre-saved snapshort of /proc/filecache from a file.
  def restore_from_file(file)
    begin
      loadfile file
    rescue => err
      $stderr.puts "#{err.backtrace.join("\n")}:", "#{err}\n\n"
    end
    @cfiles.delete_if do |key, cfile| cfile.empty? end
  end

  # Load the CachedFile info from a pre-saved files.
  def loadfile(file)

    seq = 0

    File.open(file, File::RDONLY) do |file|

      cfile = nil
      fs    = nil
      file.each_line do |line|

        next if line.empty?
        next if line[0] == ?#

        line.chomp!

        if line[0] == ?/
          if fs == nil
            fs = @@fstab[FileSystem.get_device_id(line)]
          end
          if cfile != nil
            cfile.complete
            @cfiles[cfile.file] = cfile
          end
          cfile = CachedFile.new line, fs.device_id, seq
          seq = seq + 1
        else
          idx, len = line.split
          cfile.add idx.to_i, len.to_i 
        end

      end

    end # File.open

  end

  def dump(dir)

    fds = Hash.new

    begin

    @cfiles.values.sort {|x,y| x.seq <=> y.seq} .each do |cfile|

        fd = fds[cfile.dev]
        fs = @@fstab[cfile.dev]

        next if fs == nil

        if cfile.seq == 0  # device special file 

          fd = File.open("#{dir}/#{File.basename fs.device_file}", FMODE) 
          fds[fs.device_id] = fd

        end

        fd.printf("%s", cfile.to_s) 
      end

      fds.each_value do |fd|
        fd.close
      end

    rescue => err
      $stderr.puts "#{err.backtrace.join("\n")}:", "#{err}\n\n"
    end

    self
  end

  def dump_file_list(dir)

    fds = Hash.new

    begin

    @cfiles.values.sort {|x,y| x.seq <=> y.seq} .each do |cfile|

        fd = fds[cfile.dev]
        fs = @@fstab[cfile.dev]

        next if fs == nil

        if cfile.seq == 0  # device special file 
          fd = File.open("#{dir}/#{File.basename fs.device_file}", FMODE) 
          fds[fs.device_id] = fd
        else
          fd.printf("%s\n", cfile.file) if File.stat(cfile.file).file?
        end

      end

      fds.each_value do |fd|
        fd.close
      end

    rescue => err
      $stderr.puts "#{err.backtrace.join("\n")}:", "#{err}\n\n"
    end

    self
  end

  private :loadfile

end

if $0 == __FILE__                                                                                                       
	cfiles = CachedFileList.new

	cfiles.restore_from_dir '/tmp/cache'

	cfiles2 = CachedFileList.new

	cfiles2.restore_from_dir '/tmp/cache'

	cfiles2.delete_if do |cfile|
		cfile.size > 500
	end

	cfiles2.dump '/tmp/cache2'

	# cfiles.union cfiles2
	# cfiles.intersection cfiles2
	cfiles.difference cfiles2
	# cfiles2.difference cfiles

	cfiles.dump '/tmp/cache3'
	# cfiles2.dump '/tmp/cache3'
end

# vim: ts=2 sw=2
