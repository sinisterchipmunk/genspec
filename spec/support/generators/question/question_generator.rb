base = defined?(Rails) ? Rails::Generators::Base : Thor::Group

class Question < base
  include Thor::Actions
  include CustomActions
  
  def do_acting
    act_upon "something"
  end
  
  def ask_question
    yn = ask "Are you a GOD?"
    case yn.downcase[0]
      when ?y then say "Oh, uh... Good."
      else say "You're new around here, aren't you?"
    end
  end
end
