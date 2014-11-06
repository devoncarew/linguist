module Linguist
  # A collection of simple heuristics that can be used to better analyze languages.
  class Heuristics
    ACTIVE = true

    # Public: Given an array of String language names,
    # apply heuristics against the given data and return an array
    # of matching languages, or nil.
    #
    # data      - Array of tokens or String data to analyze.
    # languages - Array of language name Strings to restrict to.
    #
    # Returns an array of Languages or []
    def self.find_by_heuristics(data, languages)
      if active?
        if languages.all? { |l| ["Perl", "Prolog"].include?(l) }
          result = disambiguate_pl(data, languages)
        end
        if languages.all? { |l| ["ECL", "Prolog"].include?(l) }
          result = disambiguate_ecl(data, languages)
        end
        if languages.all? { |l| ["IDL", "Prolog"].include?(l) }
          result = disambiguate_pro(data, languages)
        end
        if languages.all? { |l| ["Common Lisp", "OpenCL"].include?(l) }
          result = disambiguate_cl(data, languages)
        end
        if languages.all? { |l| ["Hack", "PHP"].include?(l) }
          result = disambiguate_hack(data, languages)
        end
        if languages.all? { |l| ["Scala", "SuperCollider"].include?(l) }
          result = disambiguate_sc(data, languages)
        end
        if languages.all? { |l| ["AsciiDoc", "AGS Script"].include?(l) }
          result = disambiguate_asc(data, languages)
        end
        return result
      end
    end

    # .h extensions are ambiguous between C, C++, and Objective-C.
    # We want to shortcut look for Objective-C _and_ now C++ too!
    #
    # Returns an array of Languages or []
    def self.disambiguate_c(data, languages)
      matches = []
      if data.include?("@interface")
        matches << Language["Objective-C"]
      elsif data.include?("#include <cstdint>")
        matches << Language["C++"]
      end
      matches
    end

    def self.disambiguate_pl(data, languages)
      matches = []
      if data.include?("use strict")
        matches << Language["Perl"]
      elsif data.include?(":-")
        matches << Language["Prolog"]
      end
      matches
    end

    def self.disambiguate_ecl(data, languages)
      matches = []
      if data.include?(":-")
        matches << Language["Prolog"]
      elsif data.include?(":=")
        matches << Language["ECL"]
      end
      matches
    end

    def self.disambiguate_pro(data, languages)
      matches = []
      if (data.include?(":-"))
        matches << Language["Prolog"]
      else
        matches << Language["IDL"]
      end
      matches
    end

    def self.disambiguate_ts(data, languages)
      matches = []
      if (data.include?("</translation>"))
        matches << Language["XML"]
      else
        matches << Language["TypeScript"]
      end
      matches
    end

    def self.disambiguate_cl(data, languages)
      matches = []
      if data.include?("(defun ")
        matches << Language["Common Lisp"]
      elsif /\/\* |\/\/ |^\}/.match(data)
        matches << Language["OpenCL"]
      end
      matches
    end

    def self.disambiguate_r(data, languages)
      matches = []
      matches << Language["Rebol"] if /\bRebol\b/i.match(data)
      matches << Language["R"] if data.include?("<-")
      matches
    end

    def self.disambiguate_hack(data, languages)
      matches = []
      if data.include?("<?hh")
        matches << Language["Hack"]
      elsif /<?[^h]/.match(data)
        matches << Language["PHP"]
      end
      matches
    end

    def self.disambiguate_sc(data, languages)
      matches = []
      if (/\^(this|super)\./.match(data) || /^\s*(\+|\*)\s*\w+\s*{/.match(data) || /^\s*~\w+\s*=\./.match(data))
        matches << Language["SuperCollider"]
      end
      if (/^\s*import (scala|java)\./.match(data) || /^\s*val\s+\w+\s*=/.match(data) || /^\s*class\b/.match(data))
        matches << Language["Scala"]
      end
      matches
    end

    def self.disambiguate_asc(data, languages)
      matches = []
      matches << Language["AsciiDoc"] if /^=+(\s|\n)/.match(data)
      matches
    end

    def self.active?
      !!ACTIVE
    end
  end
end
