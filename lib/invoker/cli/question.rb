module Invoker
  class CLI::Question
    def self.agree(question_text)
      $stdout.print(question_text)
      answer = $stdin.gets
      answer.strip!
      if answer =~ /\Ay(?:es)?|no?\Z/i
        answer =~ /\Ay(?:es)?\Z/i
      else
        $stdout.puts "Please enter 'yes' or 'no'."
        agree(question_text)
      end
    end
  end
end
