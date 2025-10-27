import gleam/dict
import gleam/set
import gleamspell
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn edits_distance_1_deletions_test() {
  let edits = gleamspell.edits_distance_1("cat")

  // Should contain deletions: "at", "ct", "ca"
  assert set.contains(edits, "at")
  assert set.contains(edits, "ct")
  assert set.contains(edits, "ca")
}

pub fn edits_distance_1_insertions_test() {
  let edits = gleamspell.edits_distance_1("cat")

  // Should contain insertions at the beginning
  assert set.contains(edits, "acat")
  assert set.contains(edits, "bcat")
  assert set.contains(edits, "zcat")

  // Should contain insertions in the middle
  assert set.contains(edits, "caat")
  assert set.contains(edits, "cbat")
  assert set.contains(edits, "czat")

  // Should contain insertions after second character
  assert set.contains(edits, "caat")
  assert set.contains(edits, "cabt")
  assert set.contains(edits, "cazt")

  // Should contain insertions at the end
  assert set.contains(edits, "cata")
  assert set.contains(edits, "catb")
  assert set.contains(edits, "catz")
}

pub fn edits_distance_1_transpositions_test() {
  let edits = gleamspell.edits_distance_1("cat")

  // Should contain transpositions: "act", "cta"
  assert set.contains(edits, "act")
  assert set.contains(edits, "cta")
}

pub fn edits_distance_1_replacements_test() {
  let edits = gleamspell.edits_distance_1("cat")

  // Should contain replacements like "bat", "cot", "car", etc.
  assert set.contains(edits, "bat")
  assert set.contains(edits, "cot")
  assert set.contains(edits, "car")
}

pub fn correct_with_known_words_test() {
  let frequencies =
    dict.new()
    |> dict.insert("cat", 100)
    |> dict.insert("car", 50)
    |> dict.insert("bat", 30)

  // "cot" is one edit away from "cat" (replacement), and "cat" is more frequent
  assert gleamspell.correct("cot", frequencies) == "cat"

  // "ca" is one edit away from "cat" (deletion), and "cat" is the only match
  assert gleamspell.correct("ca", frequencies) == "cat"
}

pub fn correct_with_no_known_words_test() {
  let frequencies =
    dict.new()
    |> dict.insert("cat", 100)

  // "xyz" has no edits that match known words, so return original
  assert gleamspell.correct("xyz", frequencies) == "xyz"
}
