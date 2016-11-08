module FixturesHelper
  def load_fixture(name)
    path = File.expand_path( "../fixtures/#{name}", __FILE__)
    File.read(path).strip
  end
end
