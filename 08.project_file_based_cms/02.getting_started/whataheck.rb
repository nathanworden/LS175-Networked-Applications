require 'yaml'

# p File.expand_path("../test/data", __FILE__)

# puts

# p File.expand_path("../data", __FILE__)

# p File.join("dog", "rino", "hippo")


p credentials_path = File.expand_path("../users.yml", __FILE__)

puts

p YAML.load_file(credentials_path)