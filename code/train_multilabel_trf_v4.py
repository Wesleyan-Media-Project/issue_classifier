import json
import pickle
import subprocess
import time

import datasets
import numpy as np
import pandas as pd
import torch
import transformers
from datasets import Dataset
from sklearn.model_selection import train_test_split
from tqdm.notebook import tqdm
from transformers import (
    AutoModel,
    AutoModelForSequenceClassification,
    AutoTokenizer,
    Trainer,
    TrainingArguments,
    set_seed,
)
from transformers.modeling_outputs import SequenceClassifierOutput
from transformers.trainer_callback import EarlyStoppingCallback

from sklearn import metrics
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, f1_score

pd.set_option("display.precision", 3)

''''
This script is based on Widmann and Wich's code for "Creating and Comparing Dictionary, Word Embedding, and Transformer-Based Models to Measure Discrete Emotions in German Political Text", published in Political Analysis in 2022. Article URL: https://www.cambridge.org/core/journals/political-analysis/article/creating-and-comparing-dictionary-word-embedding-and-transformerbased-models-to-measure-discrete-emotions-in-german-political-text/2DA41C0F09DE1CA600B3DCC647302637#article

Citation: Widmann, Tobias; Wich, Maximilian, 2022, "Replication Data for: Creating and Comparing Dictionary, Word Embedding, and Transformer-based Models to Measure Discrete Emotions in German Political Text", https://doi.org/10.7910/DVN/C9SAIX, Harvard Dataverse, V1; 05_train_transformer-based_classifier.ipynb [fileName]
''''

class DataLoader(torch.utils.data.Dataset):
    def __init__(self, encodings, labels):
        self.encodings = encodings
        self.labels = labels

    def __getitem__(self, idx):
        item = {key: torch.tensor(val[idx]) for key, val in self.encodings.items()}
        item['labels'] = torch.tensor(self.labels[idx])
        return item

    def __len__(self):
        return len(self.labels)

class MultilabelTrainer(Trainer):
    def compute_loss(self, model, inputs, return_outputs=False):
        labels = inputs.pop("labels")
        outputs = model(**inputs)
        logits = outputs.logits
        loss_fct = torch.nn.BCEWithLogitsLoss()
        loss = loss_fct(logits.view(-1, self.model.config.num_labels), 
                        labels.float().view(-1, self.model.config.num_labels))
        return (loss, outputs) if return_outputs else loss
    
    
def accuracy_thresh(y_pred, y_true, thresh=0.5, sigmoid=True): 
    y_pred = torch.from_numpy(y_pred)
    y_true = torch.from_numpy(y_true)
    if sigmoid:
        y_pred = y_pred.sigmoid()
    return ((y_pred>thresh)==y_true.bool()).float().mean().item()

def weighted_f1_loss(y_pred, y_true, weight=2):
    y_pred = torch.from_numpy(y_pred)
    y_pred = y_pred.sigmoid()
    y_pred[y_pred>=0.5] = 1
    y_pred[y_pred<0.5] = 0

    loss = 0
    f1_scores = []
    for i in range(len(y_true[0])):
        f1 = f1_score(y_true[:,i],y_pred.int().numpy()[:,i])
        f1_scores.append(f'{f1:9.4f}')
        loss += weight*(1 -f1)
    #print(loss, f1_scores)
    return loss

def compute_metrics(eval_pred):
    predictions, labels = eval_pred
    accuracy_thresh_value = accuracy_thresh(predictions, labels)
    weighted_f1_loss_value = weighted_f1_loss(predictions, labels)
    return {'accuracy_thresh': accuracy_thresh_value, 'f1_loss':weighted_f1_loss_value}    
    
    
def compute_fine_metrics2(eval_pred,emotions):
    metrics_result = {
        "f1": [],
        "precision": [],
        "recall": [],
        "f1_micro": [],
        "f1_macro": [],
        "f1_weighted": [],
    }
    predictions = eval_pred.predictions
    labels = eval_pred.label_ids
    predictions = torch.tensor(predictions)

    preds_full = torch.sigmoid(predictions).cpu().detach().numpy().tolist()

    preds_full = np.array(preds_full) >= 0.5
    labels = np.array(labels) >= 0.5

    for i, label in enumerate(emotions):
        column_preds = preds_full[:, i]
        column_labels = labels[:, i]
        prf1 = metrics.precision_recall_fscore_support(
            column_labels, column_preds, average="binary"
        )
        metrics_result["f1"].append(prf1[2])
        metrics_result["precision"].append(prf1[0])
        metrics_result["recall"].append(prf1[1])
        metrics_result["f1_micro"].append(
            metrics.f1_score(column_labels, column_preds, average="micro")
        )
        metrics_result["f1_macro"].append(
            metrics.f1_score(column_labels, column_preds, average="macro")
        )
        metrics_result["f1_weighted"].append(
            metrics.f1_score(column_labels, column_preds, average="weighted")
        )

    return metrics_result    

def compute_metrics_single(pred):
    labels = pred.label_ids
    preds = pred.predictions.argmax(-1)
    precision, recall, f1, _ = precision_recall_fscore_support(labels, preds, average='binary')
    acc = accuracy_score(labels, preds)
    f1_score_micro = f1_score(labels, preds, average='micro')
    f1_score_macro = f1_score(labels, preds, average='macro')
    f1_score_weighted = f1_score(labels, preds, average='weighted')
    return {
        'accuracy': acc,
        'precision': precision,
        'recall': recall,
        'f1': f1,
        'f1_micro': f1_score_micro,
        'f1_macro': f1_score_macro,
        'f1_weighted': f1_score_weighted,
    }


MODEL_NAME = "distilbert-base-uncased"
DIR_OUTPT = "./results"
DIR_LOG = "./logs"
DIR_TRAINED_MODEL = "./models/final_replication"
SIZE_VALIDATION_SET = 0.1
SEED = 7

set_seed(SEED)

df_train_validation_test = pd.read_csv('../data/issues_tv_fb_gg_22.csv')
df_train_validation_test['ISSUE209'] = df_train_validation_test['ISSUE209'].replace(2, 1)

df_train_validation, df_test = train_test_split(
    df_train_validation_test, test_size=0.1, random_state=SEED
)


issue_cols = [x for x in df_train_validation.columns if 'ISSUE' in x]
df_train_validation['list'] = df_train_validation[issue_cols].values.tolist()
df_test['list'] = df_test[issue_cols].values.tolist()

df_train, df_validation = train_test_split(
    df_train_validation, test_size=0.1, random_state=SEED
)

print("Size of training set:\t", len(df_train))
print("Size of validation set:\t", len(df_validation))
print("Size of test set:\t", len(df_test))

df_train = df_train.dropna(axis = 0)
df_validation = df_validation.dropna(axis = 0)
df_test = df_test.dropna(axis = 0)

print("Size of training set:\t", len(df_train))
print("Size of validation set:\t", len(df_validation))
print("Size of test set:\t", len(df_test))


model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME, num_labels=len(issue_cols))
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

# preprocess data
field_text = "transcript"
field_label = "list"

dataset_train = Dataset.from_pandas(df_train)
dataset_validation = Dataset.from_pandas(df_validation)
dataset_test = Dataset.from_pandas(df_test)

# tokenize data
train_encodings = tokenizer(dataset_train[field_text], truncation=True, padding=True)
val_encodings = tokenizer(dataset_validation[field_text], truncation=True, padding=True)
test_encodings = tokenizer(dataset_test[field_text], truncation=True, padding=True)

train_dataset = DataLoader(train_encodings, dataset_train[field_label])
val_dataset = DataLoader(val_encodings, dataset_validation[field_label])
test_dataset = DataLoader(test_encodings, dataset_test[field_label])

training_args = TrainingArguments(
    output_dir=DIR_OUTPT,  # output directory
    num_train_epochs=20,  # total # of training epochs (default is 4)
    per_device_train_batch_size=20,  # batch size per device during training (default 32) -- going from 16 to 25 only reduces training time a little (i.e. 1:35h instead of 1:40h), 32 shaves off another 2 minutes
    per_device_eval_batch_size=20,  # batch size for evaluation (default 32)
    warmup_steps=250,  # number of warmup steps for learning rate scheduler
    weight_decay=0.01,  # strength of weight decay
    logging_dir=DIR_LOG,  # directory for storing logs
    seed=SEED,
    eval_strategy="epoch",
    save_strategy="epoch",
    load_best_model_at_end=True,
    metric_for_best_model="f1_loss",
    greater_is_better=False,
    run_name=MODEL_NAME,
)

trainer = MultilabelTrainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=val_dataset,
    compute_metrics=compute_metrics,
)

_ = trainer.train()
trainer.evaluate()

trainer.model.save_pretrained(f"{DIR_TRAINED_MODEL}/{MODEL_NAME}/")

results_all = trainer.predict(test_dataset)

data = dict({"issue": issue_cols})
to_add = {
    "Recall": compute_fine_metrics2(results_all, issue_cols)["recall"],
    "Precision": compute_fine_metrics2(results_all, issue_cols)["precision"],
    "F1": compute_fine_metrics2(results_all, issue_cols)["f1"],
}
df = pd.DataFrame.from_dict(dict(data, **to_add))

df['F1'].mean()

df.to_csv('../performance/performance_multilabel_trf_v4.csv')


predictions = results_all.predictions
predictions = torch.tensor(predictions)
preds_full = torch.sigmoid(predictions).cpu().detach().numpy().tolist()

preds_bin = np.array(preds_full) >= 0.5
df_prds = pd.DataFrame(preds_bin)
df_prds.columns = df_train.columns[2:-1]
df_prds.to_csv("../data/test_set_prds_multilabel_trf_v4.csv")
df_test.to_csv("../data/test_set_multilabel_trf_v4.csv")
