class Skiff::Commander
  def app(role: nil)
    Skiff::Commands::App.new(config, role: role)
  end
end
