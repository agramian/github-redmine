guard :minitest do
  watch(%r{^test/(.*)\/?test_(.*)\.rb$})
  watch(%r{^lib/(.*/)?([^/]+)\.rb$})     { |m| "test/#{m[1]}test_#{m[2]}.rb" }
  watch(%r{^test/test_helper\.rb$})      { 'test' }
  watch(%r{^test/factories/(.*)\.rb$})      { 'test' }
  watch(%r{^app\.rb$})                   { 'test' }
  watch(%r{^config/(.*)$})               { 'test' }
  watch(%r{^helpers/(.*)$})              { 'test' }
  watch(%r{^models/(.*)$})               { 'test' }
  watch(%r{^setup/(.*)$})                { 'test' }
end
