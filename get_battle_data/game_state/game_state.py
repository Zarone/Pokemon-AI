class GameState:
  def __init__(self, log_lines):
    self.player1name = log_lines[0].split("|j|☆")[1].strip()
    self.player2name = log_lines[1].split("|j|☆")[1].strip()
    
    print(self.player1name, self.player2name)
    # for line in log_lines:
    #   if line.startswith("|player|"):
    #     if line.split("|p1|")

  pass