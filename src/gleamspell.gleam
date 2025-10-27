import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
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

pub fn main() -> Nil {
  case load_words("data/words.csv") {
    Ok(frequencies) -> {
      io.println("Dictionary size: " <> int.to_string(dict.size(frequencies)))

      // Check if specific words are in the dictionary
      io.println(
        "Checking 'speling': "
        <> string.inspect(dict.get(frequencies, "speling")),
      )
      io.println(
        "Checking 'spelling': "
        <> string.inspect(dict.get(frequencies, "spelling")),
      )

      let test_words = [
        "the",
        "hello",
        "spelling",
        "speling",
        "world",
        "coding",
      ]

      list.each(test_words, fn(word) {
        case is_correct(word, frequencies) {
          True -> io.println(word <> " is correctly spelled")
          False -> io.println(word <> " is misspelled")
        }
      })
    }
    Error(err) -> {
      io.println("Error: " <> err)
    }
  }
}
