base = defined?(Rails) ? Rails::Generators::Base : Thor::Group

class Question < base
  include Thor::Actions
  
  def ask_question
    yn = ask "Are you a GOD?"
    case yn.downcase[0]
      when ?y then puts "Oh, uh... Good."
      else puts "You're new around here, aren't you?"
    end
  end
end
