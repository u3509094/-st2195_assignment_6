import pandas as pd
import numpy as np
import nltk
fx = pd.read_csv("data.csv", sep = ",", header = None)
fx.columns = ["date", "value", "obs.status"]
fx = fx[["date", "value"]]
fx.info()

fx.replace("-", pd.NA, inplace = True)
fx.isna().sum()
fx.fillna(method = "bfill", inplace = True)
fx.isna().sum()

fx[["value"]] = fx[["value"]].astype(float)
fx.info()

speeches = pd.read_csv("speeches.csv", sep = "|")
speeches = speeches[["date", "contents"]]
speeches.info()

min(fx["value"])
max(fx["value"])

fx_speeches = fx.join(speeches.set_index("date"), on = "date")
fx_speeches.info()

fx_speeches.isna().sum()
fx_speeches.dropna(inplace = True)
fx_speeches.isna().sum()
fx_speeches.reset_index(drop = True, inplace = True)

for i in range(fx_speeches.shape[0]):
    if fx_speeches.loc[i, "contents"][:11] == "   SPEECH  ":
        fx_speeches.loc[i, "contents"] = fx_speeches.loc[i, "contents"][11:]
    elif fx_speeches.loc[i, "contents"][:10] == "   SPEECH ":
        fx_speeches.loc[i, "contents"] = fx_speeches.loc[i, "contents"][10:]
    else:
        continue

fx_speeches["fx_diff"] = fx_speeches["value"] - fx_speeches["value"].shift(-1)
fx_speeches["fx_per_diff"] = fx_speeches["fx_diff"] / fx_speeches["value"] * 100
fx_speeches["good_news"] = np.where(fx_speeches["fx_per_diff"] > 0.5, 1, 0)
fx_speeches["bad_news"] = np.where(fx_speeches["fx_per_diff"] < -0.5, 1, 0)

fx_good = fx_speeches.loc[fx_speeches["good_news"] == 1, ["date", "contents"]]
fx_good.reset_index(drop = True, inplace = True)
fx_bad = fx_speeches.loc[fx_speeches["bad_news"] == 1, ["date", "contents"]]
fx_bad.reset_index(drop = True, inplace = True)

for i in range(fx_good.shape[0]):
    fx_good.loc[i, "contents"] = nltk.word_tokenize(fx_good.loc[i, "contents"])

for i in range(fx_good.shape[0]):
    if i == 0:
        continue
    else:
        fx_good.loc[0, "contents"] = fx_good.loc[0, "contents"] + fx_good.loc[i, "contents"]
        fx_good.loc[i, "contents"] = []

fx_good = fx_good.loc[0, "contents"]

fx_good = pd.DataFrame(data = pd.value_counts(fx_good), columns = ["n"])
fx_good["word"] = fx_good.index
fx_good.reset_index(drop = True, inplace = True)
fx_good = fx_good[["word", "n"]]
fx_good["word"] = fx_good["word"].str.lower()
fx_good = fx_good.head(100)

connector_list = ["the", "of", "and", "in", "to", "a", "is", "that", "for", "on", "this", "as", "â", "be", "by", "are", "have", "it", "with", "has", "de", "at", "we", "which", "not", "an", "i", "will", "from", "more", "also", "been", "der", "die", "our", "would", "can", "these", "s", "their", "la", "but", "its", "or", "was", "should", "all", "they", "some", "there"]
punctuation_list = [",", ".", "(", ")", "’", "]", "[", ":", "–", "“", "”", "%"]
for i in range(len(connector_list)):
    for j in range(fx_good.shape[0]):
        if connector_list[i] == fx_good.loc[j, "word"]:
            fx_good.loc[j, "word"] = ""
        else:
            continue
        
for i in range(len(punctuation_list)):
    for j in range(fx_good.shape[0]):
        if punctuation_list[i] == fx_good.loc[j, "word"]:
            fx_good.loc[j, "word"] = ""
        else:
            continue

fx_good = fx_good[fx_good["word"] != ""]        
fx_good.reset_index(drop = True, inplace = True)
fx_good = fx_good.head(20)
fx_good.to_csv('good_indicators_python.csv')

for i in range(fx_bad.shape[0]):
    fx_bad.loc[i, "contents"] = nltk.word_tokenize(fx_bad.loc[i, "contents"])

for i in range(fx_bad.shape[0]):
    if i == 0:
        continue
    else:
        fx_bad.loc[0, "contents"] = fx_bad.loc[0, "contents"] + fx_bad.loc[i, "contents"]
        fx_bad.loc[i, "contents"] = []

fx_bad = fx_bad.loc[0, "contents"]

fx_bad = pd.DataFrame(data = pd.value_counts(fx_bad), columns = ["n"])
fx_bad["word"] = fx_bad.index
fx_bad.reset_index(drop = True, inplace = True)
fx_bad = fx_bad[["word", "n"]]
fx_bad["word"] = fx_bad["word"].str.lower()
fx_bad = fx_bad.head(100)

for i in range(len(connector_list)):
    for j in range(fx_bad.shape[0]):
        if connector_list[i] == fx_bad.loc[j, "word"]:
            fx_bad.loc[j, "word"] = ""
        else:
            continue
        
for i in range(len(punctuation_list)):
    for j in range(fx_bad.shape[0]):
        if punctuation_list[i] == fx_bad.loc[j, "word"]:
            fx_bad.loc[j, "word"] = ""
        else:
            continue

fx_bad = fx_bad[fx_bad["word"] != ""]        
fx_bad.reset_index(drop = True, inplace = True)
fx_bad = fx_bad.head(20)

good_bad_intersect = pd.Series(np.intersect1d(fx_good["word"], fx_bad["word"]))
good_bad_intersect

fx_good.to_csv('good_indicators_python.csv')
fx_bad.to_csv('bad_indicators_python.csv')
