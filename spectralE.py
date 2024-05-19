import pandas as pd
import numpy as np
import sys
import os


filename=sys.argv[1]
outputdir=sys.argv[2]
print(filename)
print(outputdir)
def spectral_entropy(x):
    x = np.array(x)
    noise = np.absolute(np.random.normal(1e-05, 1e-05, size=len(x)))
    x = x + noise
    x = x / np.sum(x)
    return(-np.sum(np.log(x) * x))

df  = pd.read_csv(filename, sep = "\t",header = None, 
                  na_values='.').fillna(0)
df.columns = df.columns.astype(str)

### #bp overlap
num_overlap = np.array(df.iloc[:,-1:].astype(float))
values = df.iloc[:,6:len(df.columns)- 1].astype(float) * num_overlap
coordinates = df.iloc[:, 0:3]
df_c = pd.concat([coordinates.reset_index(drop=True), values], axis=1)
i = df_c.groupby(['0', '1', '2']).sum()

entropy  = i.apply(spectral_entropy, axis = 0)

pd.DataFrame({
        'sample_index' : values.columns,
        'entropy' : entropy}).to_csv(outputdir+'/' + filename.split('/')[-1] + '.txt', 
            index = False)


