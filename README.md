# gleamspell
Gleam solution to [Coding Challenges](https://codingchallenges.fyi/) [build your own Spelling Correction Tool](https://codingchallenges.substack.com/p/coding-challenge-98-spelling-correction) project.

## Step 0

Get the data file from: https://www.kaggle.com/datasets/rtatman/english-word-frequency?resource=download

```sh
mkdir -p data && cd data && curl -L "https://www.kaggle.com/api/v1/datasets/download/rtatman/english-word-frequency" -o words.zip && unzip -o words.zip && mv unigram_freq.csv words.csv
```


## Step 1

```sh
gleam run
```


