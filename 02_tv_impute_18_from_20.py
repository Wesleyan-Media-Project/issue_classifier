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
issues = pd.read_csv("data/issues_of_interest.csv")
issues = issues[issues['issue_frequency']>=100]
new_issues = issues['issue_code'][issues['label18'].isna()].values
new_issues = [n for n in new_issues if n not in ['ISSUE209', 'ISSUE116']] # Kick out issues that have problematic codings and are subsets of issues 53/55 anyway

traintest = df.dropna(axis = 0)
inference = df[df['ISSUE209'].isna()]

train, test = ms.train_test_split(traintest)


clf_rf = Pipeline([('vect', CountVectorizer()),
                    ('tfidf', TfidfTransformer()),
                    ('cal', CalibratedClassifierCV(RandomForestClassifier(n_estimators=500), cv=2, method="sigmoid"),)
])

for g in new_issues:
  
  clf_rf.fit(train['transcript'], train[g])
  #clf_rf = load('models/imputation_20_to_18/issues_rf_' + g + '.joblib')
  predicted = clf_rf.predict(test['transcript'])
  
  print(metrics.classification_report(test[g], predicted))
  
  #df_p = pd.DataFrame(metrics.classification_report(test[g], predicted, output_dict=True)['weighted avg'], index = [g])
  #prfs = metrics.precision_recall_fscore_support(test[g], predicted, average='binary')
  #df_p = pd.DataFrame({'precision': prfs[0], 'recall': prfs[1], 'f1': prfs[2]}, index = [g])
  
  #df_perf = pd.DataFrame(metrics.precision_recall_fscore_support(test[g], predicted))
  #df_perf.index = ['Precision', 'Recall', 'F-Score', 'Support']
  #df_perf.to_csv(results_dir + "/" + model_name + "/" + g + '.csv')
  #perf.append(df_p)
  
  # Save model to disk
  #dump(clf_rf, 'models/imputation_20_to_18/issues_rf_' + g + '.joblib')
  
  inference[g] = clf_rf.predict(inference['transcript'])

#df_ps = pd.concat(perf)
#df_ps.to_csv("performance/random_forest.csv")

df_imputed = pd.concat([traintest, inference])
df_imputed = df_imputed.drop(columns = ['ISSUE209', 'ISSUE116'])

df_imputed.to_csv("data/issues_asr_18_20_imputed.csv", index = False)
