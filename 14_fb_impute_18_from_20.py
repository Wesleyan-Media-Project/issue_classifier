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

df = pd.read_csv("data/fb_18_20_for_imputation.csv")
issues = pd.read_csv("data/issues_of_interest.csv")
issues = issues[issues['issue_frequency']>=100]
new_issues = issues['issue_code'][issues['label18'].isna()].values
new_issues = [n for n in new_issues if n not in ['ISSUE209', 'ISSUE116']] # Kick out issues that have problematic codings and are subsets of issues 53/55 anyway

traintest = df.dropna(axis = 0)
inference = df[df['ISSUE209'].isna()]

train, test = ms.train_test_split(traintest, random_state = 123)


clf_rf = Pipeline([('vect', CountVectorizer()),
                    ('tfidf', TfidfTransformer()),
                    ('cal', CalibratedClassifierCV(RandomForestClassifier(n_estimators=500, random_state = 123), cv=2, method="sigmoid"),)
])

# Train binary issue classifiers for 2020 and then apply to 2018
# Not saving the models since training is fairly quick and models are large
for g in new_issues:
  
  print(g)
  # Train
  clf_rf.fit(train['transcript'], train[g])
  # Test
  predicted = clf_rf.predict(test['transcript'])
  print(metrics.classification_report(test[g], predicted))
  # Impute
  inference[g] = clf_rf.predict(inference['transcript'])


# Re-combine 18 and 20 sets
df_imputed = pd.concat([traintest, inference])
df_imputed = df_imputed.drop(columns = ['ISSUE209', 'ISSUE116'])
# Only keep issues we actually care about
relevant_issues = [n for n in issues['issue_code'] if n not in ['ISSUE209', 'ISSUE116']]
relevant_cols = ['alt'] + ['transcript'] + relevant_issues
df_imputed = df_imputed[relevant_cols]

df_imputed.to_csv("data/fb_18_20_imputed.csv", index = False)
