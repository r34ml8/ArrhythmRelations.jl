import numpy as np
import pandas as pd
import ruptures as rpt
import matplotlib.pyplot as plt
from lifelines import KaplanMeierFitter
from lifelines.statistics import logrank_test
from PreprocessCSV import get_data, get_windows_df

# test_path = "arrHRpy\\csv\\ReoBreath.avt.csv"
test_path = 'arrHRpy\csv\VMT_Arrh_101159.avt.csv'
df = get_data(test_path)
hr = df['hr'].values
alg = rpt.Pelt(model='l2').fit(hr)

pen_bic = 2 * np.log(len(hr)) * np.std(hr, ddof=1)**2
res = alg.predict(pen=pen_bic)
change_points = res[:-1]
rpt.display(hr, change_points, res)
plt.savefig('arrHRpy\plots\pelt_plot.png')

arr_i = df[df['arr']].index.tolist()

time_to_event = []

for i in range(len(arr_i) - 1):
    left = np.searchsorted(change_points, arr_i[i], side='left')
    right = np.searchsorted(change_points, arr_i[i+1] - 1, side='right')

    subarray = change_points[left:right]
    if len(subarray) > 0:
        time_to_event.append((arr_i[i+1] - max(subarray)) * 10)

print(time_to_event)

win_df = get_windows_df(df)
empty_i = win_df[win_df['empty_hr'] != 0].index.tolist()
empty_i += win_df[win_df['arr_hr'] != 0].index.tolist()
allowed_i = [i for i in empty_i if i not in change_points and i < arr_i[-1]]
control_i = np.random.choice(allowed_i, size=len(time_to_event)*3, replace=False)

time_to_event_control = []
for i in control_i:
    pos = np.searchsorted(arr_i, i, side='left')
    time_to_event_control.append((arr_i[pos] - i)*10)

print(time_to_event_control)  

kmf = KaplanMeierFitter()

plt.figure(figsize=(10, 6))

event_control = [True] * len(time_to_event_control)
kmf.fit(time_to_event_control, event_control, label='control')
kmf.plot_survival_function()

event = [True] * len(time_to_event)
kmf.fit(time_to_event, event, label='pelt')
kmf.plot_survival_function()

plt.savefig('arrHRpy\plots\survival.png')

results = logrank_test(time_to_event, time_to_event_control, event, event_control)
results.print_summary()



