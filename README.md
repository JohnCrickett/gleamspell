# gleamspell
Gleam solution to [Coding Challenges](https://codingchallenges.fyi/) [build your own Spelling Correction Tool](https://codingchallenges.substack.com/p/coding-challenge-98-spelling-correction) project.

This project was built with an AI agent to test it's effectiveness.

## Setup

### Step 0: Get the data file

Download the English Word Frequency dataset as so:

```sh
mkdir -p data && cd data && curl -L "https://www.kaggle.com/api/v1/datasets/download/rtatman/english-word-frequency" -o words.zip && unzip -o words.zip && mv unigram_freq.csv words.csv
```

## Running the code

### Run the spelling correction tool

```sh
gleam run
```

### Run the tests

```sh
gleam test
```


