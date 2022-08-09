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

#results_dir = 'performance'

train = pd.read_csv('data/train.csv')
test = pd.read_csv('data/test.csv')

train = train.dropna(axis = 0)
test = test.dropna(axis = 0)

clf_rf = Pipeline([('vect', CountVectorizer()),
                    ('tfidf', TfidfTransformer()),
                    ('cal', CalibratedClassifierCV(RandomForestClassifier(n_estimators=500), cv=2, method="sigmoid"),)
])

model_name = 'rf'

issue_cols = [x for x in train.columns if 'issue_' in x]
perf = []
for g in issue_cols:
  
  #clf_rf.fit(train['transcript'], train[g])
  clf_rf = load('models/issues_rf_' + g + '.joblib')
  predicted = clf_rf.predict(test['transcript'])
  
  #print(metrics.classification_report(test[g], predicted))
  
  #df_p = pd.DataFrame(metrics.classification_report(test[g], predicted, output_dict=True)['weighted avg'], index = [g])
  prfs = metrics.precision_recall_fscore_support(test[g], predicted, average='binary')
  df_p = pd.DataFrame({'precision': prfs[0], 'recall': prfs[1], 'f1': prfs[2]}, index = [g])
  
  #df_perf = pd.DataFrame(metrics.precision_recall_fscore_support(test[g], predicted))
  #df_perf.index = ['Precision', 'Recall', 'F-Score', 'Support']
  #df_perf.to_csv(results_dir + "/" + model_name + "/" + g + '.csv')
  perf.append(df_p)
  
  # Save model to disk
  dump(clf_rf, 'models/issues_rf_' + g + '.joblib')

df_ps = pd.concat(perf)
df_ps.to_csv("performance/random_forest.csv")
