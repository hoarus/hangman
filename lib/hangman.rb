require 'json'

class Hangman
  attr_reader :word, :dashes, :guess

  def initialize
    @word = select_word
    @dashes = (@word.chars.map { |char| char = '_'})
    @guess = ""
    @guess_is_correct = false
    @guesses_left = 6
    @incorrect_guesses = []
    @game_over = false
    @round = 1
    puts "\nYour robot opponent has selected a #{@word.length} letter word."
  end

  def select_word
    dictionary = 'dictionary.txt'
    lines = File.readlines(dictionary)
    filtered_dictionary = lines.select { |line| line.strip.length.between?(5,12)}
    filtered_dictionary.sample.chomp.downcase
  end

  def play_game
    play_round until @game_over == true
  end

  def play_round
    puts "\n Round #{@round}"
    puts @dashes.join(' ')
    puts "Incorrect guesses so far: #{@incorrect_guesses.join(', ')}"
    input_guess
    check_letter
    check_victory
    check_loss
    @round += 1
  end

  def input_guess
    loop do
      puts "\nYou have a total of #{@guesses_left} incorrect guesses left.\nPlease input a letter as your guess."
      @guess = gets.chomp.downcase
      if @guess == 'save'
        save_game
        break
      end
      break if valid_guess?(@guess)
      puts "Invalid guess."
    end
  end
 
  def valid_guess?(guess)
    guess.length == 1 && guess[/[a-z]+/] == guess
  end

  def check_letter
    @word.chars.each_with_index do |letter, index|
      if letter == @guess
        @dashes[index] = letter
        @guess_is_correct = true
      end
    end
    if @guess_is_correct == false
      @guesses_left -= 1
      @incorrect_guesses.push(@guess)
    end
    @guess_is_correct = false
  end

  def check_victory
    return unless @dashes.join == word
    
    @game_over = true
    puts "\nCongratulations! You have defeated your robot opponent."
    puts "The word was '#{@dashes.join}'."
  end

  def check_loss
    if @guesses_left == 0
      @game_over = true
      puts "\nOops - you have run out of guesses.\nThe word was '#{@word}'.\nGame Over..."
    end
  end

def play_again?
  loop do
    puts "\nwould you like to play again?"
    response = gets.chomp.downcase
    if ["yes","y","yeah","yep"].include?(response)
      break
    elsif ["no","n","nope","nah"].include?(response)
      puts "\nThanks for playing!"
      $program_exit = true
      break
    end
    end
  end

  def save_game
    File.write('./save-game.json', to_json)
    puts "Your game has been saved."
    puts "\nThanks for playing!"
    @game_over = true
  end

  def to_json
    JSON.dump ({
      :word => @word,
      :dashes => @dashes,
      :guess => @guess,
      :guess_is_correct => @guess_is_correct,
      :guesses_left => @guesses_left,
      :incorrect_guesses => @incorrect_guesses,
      :game_over => @game_over,
      :round => @round 
    })
  end

  def load_screen
    puts "Would you like to load your previously saved game?"
    response = gets.chomp.downcase
    if ["yes","y","yeah","yep"].include?(response)
      load_game
    else
      puts "\nWell, let's play!\nNote you can type 'save' at any point to save the game."
    end
  end

  def load_game
    file = File.read('./save-game.json')
    data = JSON.parse(file)
    @word = data['word']
    @dashes = data['dashes']
    @guess = data['guess']
    @guess_is_correct = ['guess_is_correct']
    @guesses_left = data['guesses_left']
    @incorrect_guesses = data['incorrect_guesses']
    @game_over = data['game_over']
    @round = data['round'] - 1
    puts "Your saved game has been loaded."
  end

  def self.from_json(string)
    data = JSON.load string
    self.new(data['word'], data['dashes'], data['guess'], data['guess_is_correct'], data['guesses_left'], data['incorrect_guesses'])
  end

end

puts "Hangman initialized"
$program_exit = false


until $program_exit == true do
  secret_word = Hangman.new
  secret_word.load_screen
  secret_word.play_game
  secret_word.play_again?
end

