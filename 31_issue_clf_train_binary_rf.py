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

#results_dir = 'performance'

df_train_validation_test = pd.read_csv('data/issues_tv_fb_18_20.csv')

df_train, df_test = train_test_split(
    df_train_validation_test, test_size=0.1, random_state=7
)

issue_cols = [x for x in df_train.columns if 'ISSUE' in x]

df_train = df_train.dropna(axis = 0)
df_test = df_test.dropna(axis = 0)

clf_rf = Pipeline([('vect', CountVectorizer()),
                    ('tfidf', TfidfTransformer()),
                    ('cal', CalibratedClassifierCV(RandomForestClassifier(n_estimators=500), cv=2, method="sigmoid"),)
])

model_name = 'rf'

perf = []
for g in issue_cols:
  
  clf_rf.fit(df_train['transcript'], df_train[g])
  #clf_rf = load('models/issues_rf_' + g + '.joblib')
  predicted = clf_rf.predict(df_test['transcript'])
  
  #print(metrics.classification_report(test[g], predicted))
  
  #df_p = pd.DataFrame(metrics.classification_report(test[g], predicted, output_dict=True)['weighted avg'], index = [g])
  prfs = metrics.precision_recall_fscore_support(df_test[g], predicted, average='binary')
  df_p = pd.DataFrame({'precision': prfs[0], 'recall': prfs[1], 'f1': prfs[2]}, index = [g])
  
  #df_perf = pd.DataFrame(metrics.precision_recall_fscore_support(test[g], predicted))
  #df_perf.index = ['Precision', 'Recall', 'F-Score', 'Support']
  #df_perf.to_csv(results_dir + "/" + model_name + "/" + g + '.csv')
  perf.append(df_p)
  
  # Save model to disk
  dump(clf_rf, 'models/binary_rf_v1/issues_rf_' + g + '.joblib')

df_ps = pd.concat(perf)
df_ps.to_csv("performance/performance_binomial_random_forest.csv")
