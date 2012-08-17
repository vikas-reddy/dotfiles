# Simple script to convert the MySQL SQL that the MySQL Workbench generates
# so that MS SQL Server can read it.
# WARNING - existing DB is dropped first

DB_NAME     = 'vulcan'
SCHEMA_NAME = 'vulcan'
LOGIN_NAME  = 'vulcan_dev'
USER_NAME   = 'vulcan_dev'

puts 'USE master'
puts 'GO'

puts "IF DB_ID('#{DB_NAME}') IS NOT NULL"
puts "DROP DATABASE #{DB_NAME}"
puts 'GO'
puts "CREATE DATABASE #{DB_NAME}"
puts 'GO'
puts "USE #{DB_NAME}"
puts 'GO'

puts "CREATE SCHEMA #{SCHEMA_NAME}"
puts 'GO'

# To create a login and user with default schema of vulcan

puts "DROP LOGIN #{LOGIN_NAME}"
puts 'GO'
puts "CREATE LOGIN #{LOGIN_NAME} WITH PASSWORD = 'vulcan_dev', CHECK_POLICY = OFF"
puts 'GO'
puts "CREATE USER #{USER_NAME}"
puts 'GO'
puts "ALTER USER #{USER_NAME} WITH DEFAULT_SCHEMA = #{SCHEMA_NAME}"
puts 'GO'
puts "GRANT ALTER, EXECUTE, INSERT, DELETE, UPDATE, SELECT, VIEW DEFINITION ON SCHEMA :: #{SCHEMA_NAME} to #{USER_NAME}"
puts 'GO'

# Translate from MySQL to MSSQL

puts 'BEGIN TRANSACTION'
File.readlines(ARGV[0]).each do |line|
  next if line =~ /^SET/
  next if line =~ /^CREATE SCHEMA/
  next if line =~ /^USE/
  next if line =~ /^ENGINE/

  line.gsub!('`', '')
  line.sub!('Vulcan', DB_NAME)

  # This is not needed now. DB is dropped/created. Maybe for later
  if line =~ /^DROP TABLE IF EXISTS (.*) ;/
    name = $1
    puts "IF OBJECT_ID('#{name}', 'U') IS NOT NULL"
  end

  line.sub!('INT UNSIGNED', 'BIGINT')
  line.sub!('AUTO_INCREMENT', 'IDENTITY(1,1)')
  line.sub!('IF NOT EXISTS', '')
  line.sub!('IF EXISTS', '')

  puts line
end
puts 'COMMIT'

