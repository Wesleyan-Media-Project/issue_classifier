import sklearn.model_selection as ms
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.calibration import CalibratedClassifierCV
from sklearn.naive_bayes import MultinomialNB
from sklearn import metrics
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
import pandas as pd
import numpy as np
from joblib import dump, load

df = pd.read_csv("data/issues_asr_18_20.csv")

main_cols = ["alt", "transcript"]
issue_cols = [c for c in df.columns if 'ISSUE' in c]

# Loop over all issues
for g in issue_cols:

  # Subset to only the relevant column
  traintestinf = df[main_cols + [g]]
  # Separate all the rows without NAs
  # and make them the train/test set
  traintest = traintestinf.dropna(axis = 0)
  # The rows with NAs are the inference set
  inference = traintestinf[traintestinf[g].isna()]
  
  # If the inference set contains more than 0 rows
  if len(inference) > 0:
    
      # Split
      train, test = ms.train_test_split(traintest, train_size = 0.9)
      # Train & test
      clf_rf = Pipeline([('vect', CountVectorizer()),
                          ('tfidf', TfidfTransformer()),
                          ('cal', CalibratedClassifierCV(RandomForestClassifier(n_estimators=500, random_state = 123), cv=2, method="sigmoid"),)
      ])
      clf_rf.fit(train['transcript'], train[g])
      predicted = clf_rf.predict(test['transcript'])
      print(metrics.classification_report(test[g], predicted))
      # Impute
      df.loc[inference.index, g] = clf_rf.predict(inference['transcript'])
  
  


df.to_csv("data/tv_18_20_imputed.csv", index = False)
