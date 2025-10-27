import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import simplifile

pub type WordFrequency =
  dict.Dict(String, Int)

/// Load words from a CSV file and create a word frequency table
pub fn load_words(file_path: String) -> Result(WordFrequency, String) {
  use content <- result.try(
    simplifile.read(file_path)
    |> result.map_error(fn(_) { "Failed to read file" }),
  )

  let lines = string.split(content, "\n")

  // Skip the header line and parse each line
  let words =
    lines
    |> list.drop(1)
    |> list.filter(fn(line) { string.length(line) > 0 })
    |> list.filter_map(fn(line) {
      case string.split(line, ",") {
        [word, count_str] -> {
          case int.parse(count_str) {
            Ok(count) -> Ok(#(word, count))
            Error(_) -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    })

  Ok(dict.from_list(words))
}

/// Check if a word is correctly spelled (exists in the frequency table)
pub fn is_correct(word: String, frequencies: WordFrequency) -> Bool {
  dict.has_key(frequencies, word)
}

/// Generate all edits at distance 1 from a word
/// Returns a set of all possible words that are one edit away
pub fn edits_distance_1(word: String) -> set.Set(String) {
  let len = string.length(word)
  let letters = [
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
    "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  ]

  // Deletions: remove one character
  let deletions =
    list.range(0, len)
    |> list.map(fn(i) {
      let before = string.slice(word, 0, i)
      let after = string.slice(word, i + 1, len - i - 1)
      before <> after
    })

  // Insertions: add one character at each position
  let insertions =
    list.range(0, len + 1)
    |> list.flat_map(fn(i) {
      let before = string.slice(word, 0, i)
      let after = string.slice(word, i, len - i)
      list.map(letters, fn(letter) { before <> letter <> after })
    })

  // Transpositions: swap adjacent characters
  let transpositions =
    list.range(0, len - 1)
    |> list.map(fn(i) {
      let before = string.slice(word, 0, i)
      let char1 = string.slice(word, i, 1)
      let char2 = string.slice(word, i + 1, 1)
      let after = string.slice(word, i + 2, len - i - 2)
      before <> char2 <> char1 <> after
    })

  // Replacements: replace one character with another
  let replacements =
    list.range(0, len)
    |> list.flat_map(fn(i) {
      let before = string.slice(word, 0, i)
      let after = string.slice(word, i + 1, len - i - 1)
      list.map(letters, fn(letter) { before <> letter <> after })
    })

  // Combine all edits into a set
  list.flatten([deletions, insertions, transpositions, replacements])
  |> set.from_list
}

/// Find the best correction for a misspelled word
/// Returns the most frequently occurring word from valid edits at distance 1
/// If no valid edits found, returns the original word
pub fn correct(word: String, frequencies: WordFrequency) -> String {
  // Generate all edits at distance 1
  let candidates = edits_distance_1(word)

  // Filter to only known words (words in the frequency table)
  let known_words =
    candidates
    |> set.filter(fn(candidate) { dict.has_key(frequencies, candidate) })
    |> set.to_list

  // Return the most frequently occurring word, or the original word if none found
  case known_words {
    [] -> word
    words -> {
      words
      |> list.sort(fn(a, b) {
        let freq_a = dict.get(frequencies, a) |> result.unwrap(0)
        let freq_b = dict.get(frequencies, b) |> result.unwrap(0)
        int.compare(freq_b, freq_a)
        // Sort descending by frequency
      })
      |> list.first
      |> result.unwrap(word)
    }
  }
}

pub fn main() -> Nil {
  case load_words("data/words.csv") {
    Ok(frequencies) -> {
      let test_words = [
        "speiling",
        "misteke",
        "executionw",
        "mekanism",
        "coding",
        "chalenges",
      ]

      list.each(test_words, fn(word) {
        let corrected = correct(word, frequencies)
        io.println(word <> " -> " <> corrected)
      })
    }
    Error(err) -> {
      io.println("Error: " <> err)
    }
  }
}
