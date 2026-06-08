require 'rouge'

module Rouge
  module Lexers
    class ATT < RegexLexer
      title "ATT"
      desc "AT&T syntax"
      tag 'att'
      filenames '*.s', '*.S'

      # Shorthand inclusion for Rouge token constants
      include Rouge::Token::Tokens

      def self.keywords
        @keywords ||= Set.new %w(
          mov movl movq movw movb xor xorl add addl sub subl imull
          push pushq pop popq jmp je jne jz jnz call ret syscall
          int leave enter inc dec cmp cmpl cltq
        )
      end

      state :root do
        # Comments (AT&T uses # or /)
        rule %r(#.*$), Comment::Single
        rule %r(/.*$), Comment::Single

        # Directives
        rule %r(\.[a-zA-Z0-9_]+), Name::Decorator

        # Registers (Starts with %)
        rule %r(%[a-zA-Z0-9]+), Name::Variable

        # Immediate values / constants (Starts with $)
        rule %r(\$[0-9a-fA-FxX\-]+), Literal::Number::Integer
        rule %r(\$[a-zA-Z0-9_]+), Name::Constant

        # Labels
        rule %r([a-zA-Z0-9_]+:), Name::Label

        # Keywords / Opcodes
        rule %r([a-zA-Z_][a-zA-Z0-9_]*) do |m|
          if self.class.keywords.include?(m[0])
            token Keyword
          else
            token Name
          end
        end

        # Strings
        rule %r("[^"]*"), Literal::String

        # Numbers, Punctuation, Whitespace
        rule %r([0-9]+), Literal::Number::Integer
        rule %r([,\(\)]), Punctuation
        rule %r(\s+), Text
      end
    end
  end
end