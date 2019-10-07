ARGV.each { |file|
  if file =~ /(.*)\.pbm/
    cmd = "convert #{$1}.pbm #{$1}.jpg"
    puts cmd
    system cmd
  end
}

