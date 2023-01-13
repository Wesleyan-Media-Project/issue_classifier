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

df_train_validation_test = pd.read_csv('data/tv_asr_keyword_clf.csv')

df_train, df_test = train_test_split(
    df_train_validation_test, test_size=0.2, random_state=7
)

df_train = df_train.dropna(axis = 0)
df_test = df_test.dropna(axis = 0)

#abortion
clf_rf = Pipeline([('vect', CountVectorizer()),
                    ('tfidf', TfidfTransformer()),
                    ('cal', CalibratedClassifierCV(RandomForestClassifier(n_estimators=500), cv=2, method="sigmoid"),)
])

clf_rf.fit(df_train['google_asr_text'], df_train['issue_social_abortion'])
predicted = clf_rf.predict(df_test['google_asr_text'])
prfs = metrics.classification_report(df_test['issue_social_abortion'], predicted)
# Performance of the random forest
print(prfs)
# Performance of the keywords
print(metrics.classification_report(df_test['issue_social_abortion'], df_test['predict_abortion_keyword']))

# Save model to disk
dump(clf_rf, 'models/binary_rf_2022_abortion_inflation/issues_rf_abortion.joblib')


#inflation
clf_rf_infl = Pipeline([('vect', CountVectorizer()),
                    ('tfidf', TfidfTransformer()),
                    ('cal', CalibratedClassifierCV(RandomForestClassifier(n_estimators=500), cv=2, method="sigmoid"),)
])

clf_rf_infl.fit(df_train['google_asr_text'], df_train['issue_inflation'])
predicted = clf_rf_infl.predict(df_test['google_asr_text'])
prfs = metrics.classification_report(df_test['issue_inflation'], predicted)
# Performance of the random forest
print(prfs)
# Performance of the keywords
print(metrics.classification_report(df_test['issue_inflation'], df_test['predict_inflation_keyword']))

# Save model to disk
dump(clf_rf_infl, 'models/binary_rf_2022_abortion_inflation/issues_rf_inflation.joblib')
