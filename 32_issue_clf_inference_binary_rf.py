import sklearn.model_selection as ms
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.calibration import CalibratedClassifierCV
from sklearn.naive_bayes import MultinomialNB
from sklearn import metrics
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.model_selection import train_test_split
import pandas as pd
import numpy as np
from joblib import dump, load

dir_models = 'E:/aca/clfs/issues/models'
path_inference_set = 'data/inference/tv2022_fedgov_asr_0807.csv'
path_inference_set_output = 'data/inference/tv2022_fedgov_asr_0807_output_binary_clfs.csv'

#----
# Load the inference dataset
text_field = 'google_asr_text'
df = pd.read_csv(path_inference_set)
df = df.dropna(subset = [text_field]) # remove NAs
df = df[df[text_field] != '_error'] # remove errors
df = df.reset_index(drop = True)

# Load the variable labels
with open('data/issue_labels_65.txt', 'r') as reader:
  labels = reader.read().split('\n')
labels = labels[:-1]

preds_l = []
for l in labels:
  
  clf_rf = load(dir_models + '/issues_rf_' + l + '.joblib')
  predicted = clf_rf.predict(df[text_field])
  
  preds_l.append(predicted)


df_preds = pd.DataFrame({y: x for x, y in zip(preds_l, labels)})
df_results = pd.concat([df, df_preds], axis = 1)

df_results.to_csv(path_inference_set_output)
