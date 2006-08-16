#!/usr/bin/ruby -w

# A fstab entry extended with device_id.
class FileSystem

  def FileSystem.get_device_id(device_file)

    while FileTest.symlink?(device_file)
      device_file = File.readlink(device_file)
    end

    if FileTest.exist?(device_file)

      fstat = File.stat(device_file)

      if fstat.blockdev? then
        return fstat.rdev
      end

    end

		return 0
  end

  def initialize (device_file, mount_point, fstype)

    @device_file = device_file 
    @mount_point = mount_point
    @fstype      = fstype
    @device_id   = FileSystem.get_device_id @device_file

  end


  def to_s
    "FileSystem:\t#{major}:#{minor}\t#{device_file}\t#{mount_point}\t#{fstype}"
  end

  def major()	@device_id >> 8   end
  def minor()	@device_id & 0xff	end

  attr_reader :device_id, :device_file, :mount_point, :fstype 

end

# A collection of fstab entries extended with device_id
class FSTab

  # retrieve fs entries from /etc/fstab or /etc/mtab or /proc/mounts
  def initialize (file = '/etc/fstab')

    @fstab = Hash.new

    File.open(file, 'r') do |file|
      file.each_line do |line|

				dev, mp, type, options = line.split 

				next if not dev =~ /^\s*\/dev\//
				next if mp == 'none'
				next if type == 'swap'
				next if options =~ /loop/

				fs = FileSystem.new(dev, mp, type)
				@fstab[fs.device_id] = fs

      end # file.each_line
    end  # File.open

    @fstab[0] = nil # in case we get device_id=0 for hotplug devices.
 
  end
  
  def each
    @fstab.each_value { |fs| yield(fs) }
    self
  end

  def [] (device_id)
    @fstab[device_id]
  end

  def to_s
    ret = "FSTab:\n"

    @fstab.each_value do |fs|
      ret = ret + "#{fs.to_s}\n"
    end

    ret 
  end

end

if $0 == __FILE__                                                                                                       
	fstab = FSTab.new('/etc/fstab')
	puts fstab.to_s
	puts

	fstab = FSTab.new('/etc/mtab')
	puts fstab.to_s
	puts

	fstab = FSTab.new('/proc/mounts')
	puts fstab.to_s
end

# vim: ts=2 sw=2
