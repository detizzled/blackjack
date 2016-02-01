# blackjack.rb # By Dexter Tzu

CARDS = ['ace', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'jack', 'queen', 'king']
SUITS = ['spades', 'hearts', 'clubs', 'diamonds']

def create_shoe(suits, cards)
  shoe = []
  4.times do # using 4 decks
    suits.each do |suit|
      cards.each do |card|
        card = card + '_'
        card += suit
        shoe << card
      end
    end
  end
  shoe = shoe.shuffle
end

def deal(deck)
  cards = []
  2.times do     
    card = deck.pop
    cards << card
  end
  cards
end

def remove_suit(card, suits)
  suits.each do |suit|
    suit = '_' + suit
    if card.match(suit)
      card = card.gsub(suit, '')
    end
  end
  card
end

def calculate(cards, suits = SUITS)
  new_cards = []
  cards = cards.each do |card|
    new_cards.push(remove_suit(card, suits))
  end 
  count = 0
  ace_count = 0
  new_cards.each do |card|
    case card
    when 'ace'
      if count + 11 > 21
        count += 1
      else
        count += 11
        ace_count += 1
      end
    when 'two'
      count += 2
    when 'three'
      count += 3
    when 'four'
      count += 4
    when 'five'
      count += 5
    when 'six'
      count += 6
    when 'seven'
      count += 7
    when 'eight'
      count += 8
    when 'nine'
      count += 9
    else
      count += 10
    end
  end
  if count > 21 && ace_count >= 1
    ace_count -= 1
    count -= 10
  end
  count
end

def hit(deck, cards)
  cards << deck.pop
end

def dealer_turn(computer_count, computer_cards, active_deck)
  hit(active_deck, computer_cards)
  if computer_count >= 17
    puts "computer should now stay"
  end
end

def draw_main_screen(player_name, player_count, computer_count, player_cards, computer_cards, error_message)
  system "clear"
  puts " ____   _             _   __    ___            _   __ "
  puts "| __ ) | | __ _  ____| | / /    | | __ _  ___ | | / / "
  puts "|  _ \\ | |/ _''|/ ___| |/ / __  | |/ _''|/ __|| |/ /  "
  puts "| |_) || | (_) |  |__| ._ \\ \\ \\_| | (_) | |__ | ._ \\  "
  puts "|____/ |_|\\__|_|\\___/|_| \\_\\ \\___/ \\__|_|\\___/|_| \\_\\ "
  puts "------------------------------------------------"
  puts "#{player_name}, here are your cards: "
  player_cards.each do |x| p "#{x}" end
  puts "You currently have #{player_count}, and the dealer has a #{computer_cards[0]} and a hidden card."
  if !error_message.empty?
    puts error_message
  end
end

def prompt(prompt)
  if prompt == 'main'
    puts "------------------------------------------------"
    puts "Would you like to hit or stay?  1. Hit, 2. Stay"
    puts "------------------------------------------------"
    choice = gets.chomp.to_i
    return choice
  elsif prompt == 'play_again'
    choice = ''
    while choice != "y" || choice != "n" do
      if choice == 'y'
        break
      elsif choice == 'n'
        break
      end
      puts "------------------------------------------------"
      puts "Would you like to play again? (Y)es or (N)o"
      puts "------------------------------------------------"
      choice = gets.chomp.downcase
    end
    choice
  end 
end

def bust?(cards, suits = SUITS)
  calculate(cards, suits) > 21 ? true : false
end

def blackjack?(cards, suits = SUITS)
  calculate(cards, suits) == 21 && cards.count == 2 ? true : false
end

new_game = true
player_name = ''
player_cards = []
computer_cards = []
error_message = ''
player_count = 0
computer_count = 0
stay = false
active_deck = []
busted = false
prompt = ''

loop do
  begin
    system "clear"
    puts "Welcome to Blackjack[\033[31mRuby\033[0m]. What's your name? "
    player_name = gets.chomp
    if player_name.empty?
      puts "\033[31m**** Please enter your name!\033[0m"
      sleep(1)
      next
    end
    break if player_name
  end
end

loop do 
  begin
    if new_game
      busted = false
      active_deck = create_shoe(SUITS, CARDS)
      player_cards = deal(active_deck) 
      computer_cards = deal(active_deck)
      computer_count = 0
      player_count = 0
      error_message = ''
      stay = false
      player_count = calculate(player_cards)
      computer_count = calculate(computer_cards)
    end
    if blackjack?(player_cards)
      draw_main_screen(player_name, player_count, computer_count, player_cards, computer_cards, error_message)
      puts "------------------------------------------------"
      puts "\033[31mYou got a blackjack!\033[0m"
      stay = true
    elsif blackjack?(computer_cards)
      draw_main_screen(player_name, player_count, computer_count, player_cards, computer_cards, error_message)
      puts "------------------------------------------------"
      puts "\033[31mComputer got a blackjack!\033[0m"
      stay = true
    else
      draw_main_screen(player_name, player_count, computer_count, player_cards, computer_cards, error_message)
      if busted == false
        choice = prompt('main')
      elsif busted == true
        busted = false
        choice = prompt('play_again').downcase
        if choice != 'y' || choice != 'n'
          puts "\033[31m**** Fucking *Bleep*hole!\033[0m"
          sleep(1)
          exit
        end
      end
      if choice == 1
        hit(active_deck, player_cards)
        player_count = calculate(player_cards)
        error_message = ''
        new_game = false
      elsif choice == 2
        stay = true
      else
        error_message = "\033[31m* * * Please make a proper selection! * * *\033[0m"
        new_game = false
        next
      end
    end
    if bust?(player_cards)
      error_message = "------------------------------------------------\n\033[31m* * * YOU BUSTED! * * * \033[0m\n-----------------------------------------------"
      draw_main_screen(player_name, player_count, computer_count, player_cards, computer_cards, error_message)
      new_game = false
      busted = true
      choice = prompt('play_again').downcase
      if choice == "n"
        puts "Goodbye. Until next time my friend!"
        exit
      elsif choice == "y"
        new_game = true
        prompt = 'main'
        next        
      end
    end
    if stay == true
      while computer_count < 17
        dealer_turn(computer_count, computer_cards, active_deck)
        computer_count = calculate(computer_cards)
      end
      puts "Computer's cards are #{computer_count}"
      computer_cards.each do |x| p "#{x}" end
      if computer_count > 21
        puts "\033[32m* * * Dealer busted! You win! * * * \033[0m"
      elsif computer_count == player_count
        puts "\033[32m* * * It's a TIE! * * *  \033[0m"
      elsif computer_count > player_count
        puts "\033[31m* * * You lose! Dealer wins: #{computer_count} * * *\033[0m"
      elsif player_count > computer_count
        puts "\033[32m* * * You win! * * * \033[0m"
      end
      choice = prompt('play_again').downcase
      if choice == "n"
        puts "Goodbye. See you soon."
        exit
      elsif choice == "y"
        new_game = true
        next        
      end
    end
  end
end 
