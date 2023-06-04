def load_fixture(path)
  content = File.read("spec/fixtures/#{path}")
  JSON.parse(content)
end
