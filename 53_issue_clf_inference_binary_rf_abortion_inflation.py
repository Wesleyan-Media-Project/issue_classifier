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

# In
path_inference_set = 'data/inference/fb2022.csv.gz'
# Out
path_inference_set_output = 'data/inference/fb2022_master_0905_1108_output_binary_abortion_inflation.csv'

#----
# Load the inference dataset
text_field = 'transcript'
df = pd.read_csv(path_inference_set, dtype = 'str')
df = df.dropna(subset = [text_field]) # remove NAs
df = df[df[text_field] != '_error'] # remove errors
df = df.reset_index(drop = True)

# Abortion
clf_rf_abortion = load('models/binary_rf_2022_abortion_inflation/issues_rf_abortion.joblib')
predicted_abortion = clf_rf_abortion.predict(df[text_field])

# Inflation
clf_rf_inflation = load('models/binary_rf_2022_abortion_inflation/issues_rf_abortion.joblib')
predicted_inflation = clf_rf_abortion.predict(df[text_field])



# Add results to dataframe and save
df_results = df.copy()
df_results['predicted_abortion'] = predicted_abortion
df_results['predicted_inflation'] = predicted_inflation
df_results = df_results[['id','predicted_abortion','predicted_inflation']]
df_results = df_results.rename(columns={"id": "ad_id"})

df_results.to_csv(path_inference_set_output, index = False)
