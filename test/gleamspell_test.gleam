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

pub fn correct_with_correct_word_test() {
  let frequencies =
    dict.new()
    |> dict.insert("cat", 100)
    |> dict.insert("dog", 50)

  // If the word is already correct, return it as-is
  assert gleamspell.correct("cat", frequencies) == "cat"
  assert gleamspell.correct("dog", frequencies) == "dog"
}

pub fn correct_with_distance_2_test() {
  let frequencies =
    dict.new()
    |> dict.insert("hello", 1000)
    |> dict.insert("help", 200)

  // "helo" is distance 1 from "hello" (delete l)
  assert gleamspell.correct("helo", frequencies) == "hello"

  // "hallo" is distance 1 from "hello" (replace e with a)
  // "hallo" is not in the dictionary, so should find "hello" as distance 1 correction
  assert gleamspell.correct("hallo", frequencies) == "hello"

  // "hxlpo" requires 2 edits to reach "hello" (replace x with e, replace p with l)
  // Distance 1 edits from "hxlpo" won't include "hello" or "help"
  // But distance 2 edits will include "hello"
  assert gleamspell.correct("hxlpo", frequencies) == "hello"
}

pub fn edits_distance_2_test() {
  let edits = gleamspell.edits_distance_2("hello")

  // Distance 1 edits should be included
  // Some deletions: "ello", "hllo", "helo", "hell"
  assert set.contains(edits, "ello")
  assert set.contains(edits, "hllo")
  assert set.contains(edits, "hell")

  // Some transpositions: "ehllo", "hlelo", "heoll", "helol"
  assert set.contains(edits, "ehllo")
  assert set.contains(edits, "heoll")

  // Distance 2 edits - apply two operations
  // Replace h with m, replace e with a: "mallo"
  assert set.contains(edits, "mallo")

  // Delete h, insert x at start: "xello"
  assert set.contains(edits, "xello")

  // Replace first l with r, replace second l with w: "herwo"
  assert set.contains(edits, "herwo")

  // Delete e, insert a: "hallo"
  assert set.contains(edits, "hallo")

  // Transpose h and e: "ehllo", then replace first l with r: "ehrlo"
  assert set.contains(edits, "ehrlo")

  // Insert x at start, insert y at end: "xhelloy"
  assert set.contains(edits, "xhelloy")
}
