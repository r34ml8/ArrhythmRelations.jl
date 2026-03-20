import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import kendalltau, theilslopes, mannwhitneyu
import sys
sys.path.insert(0, "arrHRpy\PreprocessCSV.py")
from PreprocessCSV import get_data, get_windows_df, WINDOWS

def linear_model(win_df: pd.DataFrame, win_i: int = 0):
    arr_values = get_values(win_df, "arr_hr")
    arr_df = pd.DataFrame({
        "values": arr_values,
        "kendall": kendallcor(arr_values, win_i),
        "theilsen": theilsen(arr_values, win_i)
    })

    empty_values = get_values(win_df, "empty_hr")
    empty_df = pd.DataFrame({
        "values": empty_values,
        "kendall": kendallcor(empty_values, win_i),
        "theilsen": theilsen(empty_values, win_i)
    })

    return arr_df, empty_df

def get_values(win_df: pd.DataFrame, column: str):
    array = win_df[column].to_numpy()
    zero_indices = np.where(array == 0)[0]
    subarrays = np.split(array, zero_indices)
    values = [sub[sub != 0] for sub in subarrays if sub.size > 0 and np.any(sub != 0)]
    return values


def kendallcor(values: np.array, win_i: int = 0):
    time = np.arange(WINDOWS[win_i])

    kendall = []
    for el in values:
        tau, p = kendalltau(el, time)
        kendall.append(tau)

    return kendall

def theilsen(values: np.array, win_i: int = 0):
    time = np.arange(WINDOWS[win_i])

    theil = []
    for el in values:
        res = theilslopes(el, time)
        theil.append(res.slope)

    return theil

def get_stats(path: str, win_i: int = 0):
    data = get_data(path)
    df = get_windows_df(data, win_i)
    arr_df, empty_df = linear_model(df, win_i)
    _, mw_kendall = mannwhitneyu(arr_df["kendall"], empty_df["kendall"], alternative="two-sided")
    _, mw_theil = mannwhitneyu(arr_df["theilsen"], empty_df["theilsen"], alternative="two-sided")
    return mw_kendall, mw_theil


test_path = "arrHRpy\\csv\\ReoBreath.avt.csv"
a = get_data(test_path)
b = get_windows_df(a, 1)
arr, empty = linear_model(b, 1)

plt.figure(figsize=(8, 6))
plt.scatter(empty["kendall"], empty["theilsen"], color='blue', label='empty', alpha=0.7)
plt.scatter(arr["kendall"], arr["theilsen"], color='red', label='arr', alpha=0.7)
plt.savefig('arrHRpy\plots\linear_scatterplot.png', dpi=300)

plt.figure(figsize=(6, 6))
plt.hist(empty["kendall"], alpha=0.5, label='empty', color='blue', density=True)
plt.hist(arr["kendall"], alpha=0.5, label='arr', color='red', density=True)
plt.savefig('arrHRpy\plots\linear_histkendall.png', dpi=300)

plt.figure(figsize=(6, 6))
plt.hist(empty["theilsen"], alpha=0.5, label='empty', color='blue', density=True)
plt.hist(arr["theilsen"], alpha=0.5, label='arr', color='red', density=True)
plt.savefig('arrHRpy\plots\linear_histtheilsen.png', dpi=300)